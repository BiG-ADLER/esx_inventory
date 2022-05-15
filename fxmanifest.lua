resource_manifest_version "44febabe-d386-4d18-afbe-5e627f4af937"

author 'theMani_kh'
description 'QBCore Inventory converted to ESX'

ui_page {'html/ui.html'}  --Not Wrote by Me :(

server_scripts {
    '@mysql-async/lib/MySQL.lua',
    "config.lua",
    "server/main.lua",
    "server/weapon.lua",
}

client_scripts {
    "config.lua",
    "client/main.lua",
    "client/weapon.lua",
    "client/shop.lua",
}

exports {
    'GetAmmoType',
}

server_exports {
    'AddToStash',
    'GetWeaponList',
}

files {
    'html/ui.html',
    'html/css/main.css',
    'html/js/app.js',
    'html/images/*.png',
    'html/images/*.jpg',
    'html/ammo_images/*.png',
    'html/attachment_images/*.png',
    'html/*.ttf',
}