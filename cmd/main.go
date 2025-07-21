package main

import (
	"context"
	"log"
	"os"
	"os/signal"
	"syscall"

	flag "github.com/spf13/pflag"

	operator "github.com/Dbaker1298/grafzahl/pkg/operator"
)

var options operator.Options

func init() {
	flag.StringVarP(&options.KubeConfig, "kubeconfig", "c", "", "Path to kubeconfig file with authorization and master location information.")
}

func run() error {
	// Set logging output to standard console out
	log.SetOutput(os.Stdout)
	flag.Parse()

	log.Printf("Starting Grafzahl Operator %s", operator.VERSION)

	ctx, cancel := signal.NotifyContext(context.Background(), os.Interrupt, syscall.SIGTERM)
	defer cancel()

	grafzahl, err := operator.New(options)
	if err != nil {
		return err
	}

	if err := grafzahl.Run(ctx); err != nil {
		return err
	}

	log.Printf("shutting down grafzahl v%s...", operator.VERSION)
	return nil
}

func main() {
	if err := run(); err != nil {
		log.Fatal(err)
	}
}
