::Sprockets::ES6.instance.instance_exec do
  @options = @options.merge(
    stage: 0,
    modules: :ignore,
    moduleIds: true
  )
  @cache_key = [*@cache_key[0..2], @options]
end