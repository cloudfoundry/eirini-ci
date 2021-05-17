package parser

import (
	"bufio"
	"io"
	"regexp"
)

type Chunker struct{}

func NewChunker() Chunker {
	return Chunker{}
}

func (c Chunker) Chunk(input io.Reader) [][]string {
	var chunks [][]string

	scanner := bufio.NewScanner(input)

	hasBackspace := regexp.MustCompile(` \x08`)
	chunk := []string{}

	inChunk := false

	for scanner.Scan() {
		line := scanner.Text()
		if line == "" {
			continue
		}

		switch inChunk {
		case false:
			if hasBackspace.MatchString(line) {
				inChunk = true
				chunk = append(chunk, line)
			}

		case true:
			if !hasBackspace.MatchString(line) {
				inChunk = false
				chunks = append(chunks, chunk)
				chunk = []string{}
				continue
			}
			chunk = append(chunk, line)
		}
	}

	if inChunk {
		chunks = append(chunks, chunk)
	}

	return chunks
}
