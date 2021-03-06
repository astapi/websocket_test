defmodule WebsocketTest.Mixfile do
  use Mix.Project

  def project do
    [app: :websocket_test,
     version: "0.0.1",
     elixir: "~> 1.2",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps]
  end

  # Configuration for the OTP application
  #
  # Type "mix help compile.app" for more information
  def application do
    [applications: [:logger]]
  end

  defp deps do
    [
      {:websocket_client, git: "https://github.com/jeremyong/websocket_client.git"},
      {:poison, "~> 2.0"},
      {:phoenix, "~> 1.1.0"}
    ]
  end
end
