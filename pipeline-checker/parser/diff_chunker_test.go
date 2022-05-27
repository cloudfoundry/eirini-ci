package parser_test

import (
	"fmt"
	"io"
	"strings"

	. "github.com/onsi/ginkgo/v2"
	. "github.com/onsi/gomega"

	"github.com/eirini-forks/pipelinechecker/parser"
)

var _ = Describe("Diffchunker", func() {
	var (
		input    io.Reader
		inputStr string
		chunker  parser.Chunker
		output   [][]string
	)

	BeforeEach(func() {
		inputStr = ""
	})

	JustBeforeEach(func() {
		input = strings.NewReader(inputStr)
		chunker = parser.NewChunker()
		output = chunker.Chunk(input)
	})

	It("returns no chunks for empty input", func() {
		Expect(output).To(BeEmpty())
	})

	When("input contains chunks", func() {
		BeforeEach(func() {
			inputStr = fmt.Sprintf(`
   source:
   %[1]s-   access_token: adfasdlfkjadskj
   %[1]s-+   access_token: fakepassword
     drafts: true
   target:
   %[1]s--   access_token: fdkfji22
   %[1]s-+   access_token: fakepassword
     drafts: true
   %[1]s--   password: fdkfji23
     drafts: false
     originals: true
   %[1]s-+   key: g major`, "\x08\x08")
		})

		It("splits the input into chunks", func() {
			Expect(output).To(HaveLen(4))

			expectChunkToConsistOf(output[0], "adfasdlfkjadskj", "fakepassword")
			expectChunkToConsistOf(output[1], "fdkfji22", "fakepassword")
			expectChunkToConsistOf(output[2], "fdkfji23")
			expectChunkToConsistOf(output[3], "g major")
		})
	})
})

func expectChunkToConsistOf(chunk []string, substrings ...string) {
	Expect(len(chunk)).To(Equal(len(substrings)))

	for i, substr := range substrings {
		Expect(chunk[i]).To(ContainSubstring(substr))
	}
}
