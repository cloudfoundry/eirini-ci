package integration_test

import (
	"fmt"
	"io"
	"os/exec"
	"strings"

	. "github.com/onsi/ginkgo"
	. "github.com/onsi/gomega"
	"github.com/onsi/gomega/gbytes"
	"github.com/onsi/gomega/gexec"
)

var _ = Describe("Integration", func() {
	var (
		session *gexec.Session
		input   io.Reader
	)

	BeforeEach(func() {
		input = strings.NewReader("")
	})

	AfterEach(func() {
		Eventually(session.Kill()).Should(gexec.Exit())
	})

	JustBeforeEach(func() {
		cmd := exec.Command(binPath)
		cmd.Stdin = input

		var err error
		session, err = gexec.Start(cmd, GinkgoWriter, GinkgoWriter)
		Expect(err).NotTo(HaveOccurred())
	})

	When("there is no input", func() {
		It("returns 0", func() {
			Eventually(session).Should(gexec.Exit(0))
		})
	})

	When("there are just pass secrets in the diff", func() {
		BeforeEach(func() {
			input = strings.NewReader(fmt.Sprintf(`
  stuff
  %[1]s- myField: dfjwlefj
  %[1]s+ myField: fakepassword
  nonsense
`, "\x08\x08"))
		})

		It("returns 0 with no output", func() {
			Eventually(session).Should(gexec.Exit(0))
			Expect(string(session.Err.Contents())).To(BeEmpty())
		})
	})

	When("there is a real change in the diff", func() {
		BeforeEach(func() {
			input = strings.NewReader(fmt.Sprintf(`
  stuff
  %[1]s- myField: old field
  nonsense
`, "\x08\x08"))
		})

		It("returns 1 with the diff", func() {
			Eventually(session).Should(gexec.Exit(1))
			Expect(session.Err).To(gbytes.Say("myField: old field"))
		})
	})

	When("there is single line added", func() {
		BeforeEach(func() {
			input = strings.NewReader(fmt.Sprintf(`
  stuff
  %[1]s+ myField: new field
  nonsense
`, "\x08\x08"))
		})

		It("returns 1 with the diff", func() {
			Eventually(session).Should(gexec.Exit(1))
			Expect(session.Err).To(gbytes.Say("myField: new field"))
		})
	})
})
