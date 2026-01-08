package main;

import (
	"io"
	"fmt"
	"strings"
	"context"
	"text/template"
	"net/http"

	"cloud.google.com/go/storage"
	"google.golang.org/api/iterator"
	"github.com/goccy/go-yaml"
);

type Service struct {
	Name		string			`yaml:"name"`
	RepositoryLink	string			`yaml:"repository_link"`
	Tag		string			`yaml:"tag"`
	TagLink		string			`yaml:"tag_link"`
	Type		string			`yaml:"type"`	
	Ingress		bool			`yaml:"ingress"`
	Hosts		[]string			
	AdditionalHosts	[]string		`yaml:"additional_hosts"`
	Public		bool			`yaml:"public"`
	AllowedNetworks	map[string][]string	`yaml:"allowed_networks"`
	Requires	[]string		`yaml:"requires"`
	RequiresCsv	string		
	HealthCheckPath	string			`yaml:"health_check_path"`
}

type HtmlTemplate struct {
	Title			string
	Environment		string
	ServiceGroupBaseUrl	string
	Services		[]Service
}

func index(w http.ResponseWriter, r *http.Request) {
	/* Configuration */
	github_base_url := os.Getenv("GITHUB_ORG_URL");
	management_project := os.Getenv("MANAGEMENT_PROJECT");
	values_bucket := fmt.Sprintf("%s-values", management_project);

	environment := os.Getenv("ENVIRONMENT");
	title := os.Getenv("SERVICE_GROUP_TITLE");
	service_group := os.Getenv("SERVICE_GROUP");
	service_group_host := os.Getenv("SERVICE_GROUP_HOST");
	prefix := fmt.Sprintf("%s/%s/", environment, service_group);

	/* Google Cloud Storage client */
	ctx := context.Background();
	client, err := storage.NewClient(ctx);
	if err != nil {
	    panic(err);
	}

	/* Iterate service files */
	query := &storage.Query {
		Prefix: fmt.Sprintf("%s/%s", environment, service_group),
	};
	it := client.Bucket(values_bucket).Objects(ctx, query);
	var html_template HtmlTemplate;
	html_template.Title = title;
	html_template.Environment = environment;
	html_template.ServiceGroupBaseUrl = service_group_host;
	for {
		/* Get the next file */
		attrs, err := it.Next();
		if err == iterator.Done {
			break
		}
		if err != nil {
			panic(err);
		}

		/* Read file */
		rc, err := client.Bucket(values_bucket).Object(
			attrs.Name,
		).NewReader(ctx);
		if err != nil {
			panic(err);
		}
		defer rc.Close()
		body, err := io.ReadAll(rc);
		if err != nil {
			panic(err);
		}

		/* Parse YAML */
		var service Service;
		err = yaml.Unmarshal([]byte(body), &service);
		if err != nil {
			panic(err);
		}

		/* Set additional properties */
		service.Name = strings.TrimSuffix(
			strings.TrimPrefix(attrs.Name, prefix),
			".yaml",
		);
		service.RepositoryLink = fmt.Sprintf(
			"%s/%s-%s",
			github_base_url,
			service_group,
			service.Name,
		);
		service.TagLink = fmt.Sprintf(
			"%s/tree/%s",
			service.RepositoryLink,
			service.Tag,
		);

		/* Set hosts */
		service.Hosts = append(
			service.Hosts,
			fmt.Sprintf(
				"https://%s.%s",
				service.Name,
				service_group_host,
			),
		);
		for _, ah := range service.AdditionalHosts {
			service.Hosts = append(
				service.Hosts,
				fmt.Sprintf(
					"https://%s.%s",
					ah,
					service_group_host,
				),
			);
		}
		
		/* Required Services */
		service.RequiresCsv = strings.Join(service.Requires, ", ");

		/* Health Check */
		if len(service.HealthCheckPath) == 0 {
			service.HealthCheckPath = "/health";
		}

		html_template.Services = append(
			html_template.Services,
			service,
		);

	}

	/* Templating */
	t, err := template.ParseFiles("resources/services.html");
	if err != nil {
	    panic(err);
	}
	
	err = t.Execute(w, html_template)
	if err != nil {
	    panic(err);
	}
}

func main() {
	http.HandleFunc("/", index);
	http.ListenAndServe(":8080", nil)
}

