fx_version 'adamant'

game 'gta5'

description 'Plantation de weed'

client_scripts {
    '@es_extended/locale.lua',
    'client/cl-weedp.lua',
}

server_scripts { 
    '@async/async.lua',
    '@es_extended/locale.lua',
    '@mysql-async/lib/MySQL.lua',
    'server/sv-weedp.lua', 
}

dependencies {
    'async',
    'es_extended',
    'mysql-async'
}
