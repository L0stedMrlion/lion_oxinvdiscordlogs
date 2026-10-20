local routes = {
    evidence_put = { from = 'player', to = 'policeevidence', webhook = 'evidence', verb = 'placed into evidence' },
    evidence_take = { from = 'policeevidence', to = 'player', webhook = 'evidence', verb = 'took from evidence' },
    trunk_put = { from = 'player', to = 'trunk', webhook = 'trunk', verb = 'placed in a vehicle trunk' },
    trunk_take = { from = 'trunk', to = 'player', webhook = 'trunk', verb = 'took from a vehicle trunk' },
    glovebox_put = { from = 'player', to = 'glovebox', webhook = 'trunk', verb = 'placed in a vehicle glovebox' },
    glovebox_take = { from = 'glovebox', to = 'player', webhook = 'trunk', verb = 'took from a vehicle glovebox' },
    drop = { from = 'player', to = 'drop', webhook = 'drop', verb = 'dropped' },
    pickup = { from = 'drop', to = 'player', webhook = 'pickup', verb = 'picked up' },
    stash_put = { from = 'player', to = 'stash', webhook = 'stash', verb = 'placed into a stash' },
    stash_take = { from = 'stash', to = 'player', webhook = 'stash', verb = 'took from a stash' },
    container_put = { from = 'player', to = 'container', webhook = 'container', verb = 'placed into a container' },
    container_take = { from = 'container', to = 'player', webhook = 'container', verb = 'took from a container' },
    container_transfer = { from = 'container', to = 'container', webhook = 'container', verb = 'moved between containers' },
    give = { from = 'player', to = 'player', webhook = 'give', verb = 'transferred to another player' }
}

return routes
