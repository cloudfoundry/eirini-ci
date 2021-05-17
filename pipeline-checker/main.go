package main

import (
	"log"
	"os"
	"strings"

	"github.com/eirini-forks/pipelinechecker/parser"
)

func main() {
	block := parser.NewChunker()
	backspace := parser.NewSanitizer()
	multiline := parser.NewMultilineChomper()
	fields := parser.NewFieldChecker("fakepassword")

	allDiffs := []string{}

	for _, chunk := range block.Chunk(os.Stdin) {
		sanitizedChunk := backspace.Sanitize(chunk)

		if !fields.Check(multiline.Chomp(sanitizedChunk)) {
			allDiffs = append(allDiffs, "")
			allDiffs = append(allDiffs, sanitizedChunk...)
		}
	}

	if len(allDiffs) > 0 {
		log.Fatalf("Pipeline is out of date\n%s", strings.Join(allDiffs, "\n"))
	}
}
