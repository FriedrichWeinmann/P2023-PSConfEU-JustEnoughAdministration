@{
	# For logging purposes and to declare dependencies
	Name = 'JEA_CimAccess'

	# Targets affected (see Targets folder)
	Target = 'All'

	# Name of the Action to execute
	Action = 'Jea Endpoint'

	# The bloody parameters the action needs
	Parameters = @{
		# Name of the Endpoint to deploy Must be stored in 'resources\JEA'
		Name = 'JEA_CimAccess'
	}
}