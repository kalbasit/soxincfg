locals {
  admin_users_csv = csvdecode(file("${path.module}/admin_users.csv"))
  admin_users     = { for user in local.admin_users_csv : user.mac => user }

  general_users_csv = csvdecode(file("${path.module}/general_users.csv"))
  general_users     = { for user in local.general_users_csv : user.mac => user }

  server_network_0_users_csv = csvdecode(file("${path.module}/server_network_0_users.csv"))
  server_network_0_users     = { for user in local.server_network_0_users_csv : user.mac => user }
}

resource "unifi_user" "admin_user" {
  for_each = local.admin_users

  network_id = unifi_network.admin.id

  fixed_ip = each.value.fixed_ip

  mac  = each.key
  name = each.value.name
  # append an optional additional note
  note = trimspace("${each.value.note}\n\nmanaged by TF")
}

resource "unifi_user" "general_user" {
  for_each = local.general_users

  network_id = unifi_network.general.id

  fixed_ip = each.value.fixed_ip

  mac  = each.key
  name = each.value.name
  # append an optional additional note
  note = trimspace("${each.value.note}\n\nmanaged by TF")
}

resource "unifi_user" "server_network_0_user" {
  for_each = local.server_network_0_users

  network_id = unifi_network.server_network_0.id

  fixed_ip = each.value.fixed_ip

  mac  = each.key
  name = each.value.name
  # append an optional additional note
  note = trimspace("${each.value.note}\n\nmanaged by TF")
}
