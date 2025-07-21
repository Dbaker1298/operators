package operator

import (
	"context"
	"fmt"
	"log"
	"time"

	"k8s.io/client-go/kubernetes"
	"k8s.io/client-go/rest"
	"k8s.io/client-go/tools/clientcmd"
)

var (
	VERSION               = "0.0.0.dev"
	defaultResyncInterval = time.Second * 10
)

type Options struct {
	KubeConfig string
}

type Grafzahl struct {
	Options
	clientset         *kubernetes.Clientset
	podwatcher        *podWatcher
	deploymentwatcher *deploymentWatcher
}

func New(options Options) (*Grafzahl, error) {

	config, err := newClientConfig(options)
	if err != nil {
		return nil, fmt.Errorf("config: %w", err)
	}

	clientset, err := kubernetes.NewForConfig(config)
	if err != nil {
		return nil, fmt.Errorf("clientset: %w", err)
	}

	gz := &Grafzahl{
		Options:           options,
		clientset:         clientset,
		podwatcher:        newPodWatcher(clientset),
		deploymentwatcher: newDeploymentWatcher(clientset),
	}

	return gz, nil
}

func (gz *Grafzahl) Run(ctx context.Context) error {
	log.Printf("Grafzahl %v is ready to count \n", VERSION)

	stopChan := make(chan struct{})

	go gz.podwatcher.run(stopChan)
	go gz.deploymentwatcher.run(stopChan)

	select {
	case <-ctx.Done():
		close(stopChan)
		break
	}

	return nil
}

func newClientConfig(options Options) (*rest.Config, error) {

	defaultRules := clientcmd.NewDefaultClientConfigLoadingRules()

	if options.KubeConfig != "" {
		defaultRules.ExplicitPath = options.KubeConfig
	}

	config, err := clientcmd.NewNonInteractiveDeferredLoadingClientConfig(defaultRules, nil).ClientConfig()
	if err != nil {
		log.Printf("Error loading the config file, trying in cluster config ...")
		config, err = rest.InClusterConfig()
		if err != nil {
			return nil, fmt.Errorf("Creating in-cluster config failed: %w", err)
		}
	}

	return config, nil

}
