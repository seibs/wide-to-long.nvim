((function_definition
  parameters: (parameters) @args
) @target-node)

((expression_statement
  (call arguments: (argument_list) @args)
) @target-node)

((expression_statement
  (assignment
    (call arguments: (argument_list) @args))
) @target-node)
