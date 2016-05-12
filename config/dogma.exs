use Mix.Config
alias Dogma.Rule

config :dogma,
  rule_set: Dogma.RuleSet.All,

  exclude: [
    ~r(\Alib/vendor/),
  ],

  override: [
    %Rule.LineLength{ enabled: false },
    %Rule.ModuleDoc{ enabled: false},
    %Rule.PipelineStart{ enabled: false},
    %Rule.MatchInCondition{ enabled: false }
  ]
