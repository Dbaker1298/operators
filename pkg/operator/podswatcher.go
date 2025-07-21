package operator

import (
	"fmt"

	corev1 "k8s.io/api/core/v1"
	kubeinformers "k8s.io/client-go/informers"
	"k8s.io/client-go/kubernetes"
	"k8s.io/client-go/tools/cache"
)

type podWatcher struct {
	podInformer cache.SharedIndexInformer
}

func newPodWatcher(client *kubernetes.Clientset) *podWatcher {
	kubeInformerFactory := kubeinformers.NewSharedInformerFactory(client, defaultResyncInterval)

	podInformer := kubeInformerFactory.Core().V1().Pods().Informer()

	podInformer.AddEventHandler(cache.ResourceEventHandlerFuncs{
		AddFunc: func(obj interface{}) {
			pod := obj.(*corev1.Pod)
			fmt.Printf("pod added: %s/%s\n", pod.Namespace, pod.Name)
		},
		DeleteFunc: func(obj interface{}) {
			fmt.Printf("pod deleted: %s \n", obj)
		},
		UpdateFunc: func(oldObj, newObj interface{}) {
			fmt.Printf("pod updated: %s \n", newObj)
		},
	})

	return &podWatcher{podInformer: podInformer}
}

func (p *podWatcher) run(stopChan <-chan struct{}) {
	p.podInformer.Run(stopChan)
}
