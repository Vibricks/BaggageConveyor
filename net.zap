opt server_output = "src/Server/ServerRemotes.luau"
opt client_output = "src/Client/ClientRemotes.luau"

opt casing = "camelCase"



event requestState ={
    from: Client,
	type: Reliable,
	call: SingleAsync,
	data: unknown,
}

event replicateState ={
    from: Server,
	type: Reliable,
	call: SingleAsync,
	data: unknown,
}
