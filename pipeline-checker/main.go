package main

import (
	"log"
	"os"

	"github.com/eirini-forks/pipelinechecker/parser"
)

func main() {
	block := parser.NewChunker()
	backspace := parser.NewSanitizer()
	multiline := parser.NewMultilineChomper()
	fields := parser.NewFieldChecker("fakepassword")

	for _, chunk := range block.Chunk(os.Stdin) {
		sanitizedChunk := backspace.Sanitize(chunk)

		if !fields.Check(multiline.Chomp(sanitizedChunk)) {
			log.Fatalf("Pipeline is out of date\n\nRun `$HOME/workspace/eirini-ci/pipelines/set-all-pipelines` to see the problem\n")
		}
	}
}
