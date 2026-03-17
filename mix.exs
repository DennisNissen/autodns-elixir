defmodule AutoDNS.MixProject do
  use Mix.Project

  @version "0.1.0"
  @source_url "https://github.com/DennisNissen/autodns-elixir"

  def project do
    [
      app: :autodns,
      version: @version,
      elixir: "~> 1.14",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      name: "AutoDNS",
      description: "Elixir client for the AutoDNS JSON API (InterNetX)",
      source_url: @source_url,
      docs: docs(),
      package: package(),
      elixirc_paths: elixirc_paths(Mix.env())
    ]
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  defp deps do
    [
      {:req, "~> 0.5"},
      {:jason, "~> 1.4"},
      {:plug, "~> 1.14", only: :test},
      {:ex_doc, "~> 0.31", only: :dev, runtime: false}
    ]
  end

  defp docs do
    [
      main: "AutoDNS",
      extras: ["README.md", "PLAN.md"],
      groups_for_modules: [
        Core: [
          AutoDNS,
          AutoDNS.Client,
          AutoDNS.Response,
          AutoDNS.Error
        ],
        "Domain Management": [
          AutoDNS.Domains,
          AutoDNS.DomainCancelations,
          AutoDNS.DomainPreregs,
          AutoDNS.DomainPremiums,
          AutoDNS.DomainStudio,
          AutoDNS.DomainSafe,
          AutoDNS.TransferOuts
        ],
        "DNS / Zones": [
          AutoDNS.Zones,
          AutoDNS.ZoneQueries
        ],
        Contacts: [
          AutoDNS.Contacts,
          AutoDNS.ContactDocuments
        ],
        "SSL / Certificates": [
          AutoDNS.Certificates,
          AutoDNS.SslContacts
        ],
        "Users & Auth": [
          AutoDNS.Users,
          AutoDNS.OTPAuth,
          AutoDNS.Session
        ],
        "Jobs & Polling": [
          AutoDNS.Jobs,
          AutoDNS.Polls
        ],
        Infrastructure: [
          AutoDNS.BackupMx,
          AutoDNS.MailProxies,
          AutoDNS.Redirects
        ],
        "Billing & Account": [
          AutoDNS.Account,
          AutoDNS.Invoices,
          AutoDNS.Subscriptions,
          AutoDNS.SubjectProducts
        ],
        Trademark: [
          AutoDNS.TmchMarks,
          AutoDNS.TmchClaims
        ]
      ]
    ]
  end

  defp package do
    [
      licenses: ["MIT"],
      links: %{"GitHub" => @source_url}
    ]
  end
end
