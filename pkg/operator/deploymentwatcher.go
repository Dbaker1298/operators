package operator

import (
	"fmt"

	appsv1 "k8s.io/api/apps/v1"
	kubeinformers "k8s.io/client-go/informers"
	"k8s.io/client-go/kubernetes"
	"k8s.io/client-go/tools/cache"
)

type deploymentWatcher struct {
	deploymentInformer cache.SharedIndexInformer
}

func onAddDeployment(obj interface{}) {
	deployment := obj.(*appsv1.Deployment)
	fmt.Printf("deployment added: %s/%s\n", deployment.Namespace, deployment.Name)
}

func newDeploymentWatcher(client *kubernetes.Clientset) *deploymentWatcher {
	kubeInformerFactory := kubeinformers.NewSharedInformerFactory(client, defaultResyncInterval)

	deploymentInformer := kubeInformerFactory.Apps().V1().Deployments().Informer()

	deploymentInformer.AddEventHandler(cache.ResourceEventHandlerFuncs{
		AddFunc: onAddDeployment,
		DeleteFunc: func(obj interface{}) {
			fmt.Printf("deployment deleted: %s \n", obj)
		},
		UpdateFunc: func(oldObj, newObj interface{}) {
			fmt.Printf("deployment updated: %s \n", newObj)
		},
	})

	return &deploymentWatcher{deploymentInformer: deploymentInformer}
}

func (d *deploymentWatcher) run(stopChan <-chan struct{}) {
	d.deploymentInformer.Run(stopChan)
}
