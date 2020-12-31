resource "unifi_firewall_rule" "isolate_guest_0" {
  for_each = {
    General = {
      id         = unifi_network.general.id
      rule_index = 2000
    }

    Admin = {
      id         = unifi_network.admin.id
      rule_index = 2001
    }

    "Server Network 0" = {
      id         = unifi_network.server_network_0.id
      rule_index = 2002
    }
  }

  name    = "drop all from Guest0 to ${each.key}"
  action  = "drop"
  ruleset = "LAN_IN"

  rule_index = each.value.rule_index

  protocol = "all"

  src_network_id = unifi_network.guest_0.id
  dst_network_id = each.value.id
}

resource "unifi_firewall_rule" "isolate_admin" {
  for_each = {
    General = {
      id         = unifi_network.general.id
      rule_index = 2010
    }

    "Guest 0" = {
      id         = unifi_network.guest_0.id
      rule_index = 2011
    }

    "Server Network 0" = {
      id         = unifi_network.server_network_0.id
      rule_index = 2012
    }
  }

  name    = "drop all from ${each.key} to Admin"
  action  = "drop"
  ruleset = "LAN_IN"

  rule_index = each.value.rule_index

  protocol = "all"

  src_network_id = each.value.id
  dst_network_id = unifi_network.admin.id

  state_established = false
  state_related     = false

  state_invalid = true
  state_new     = true
}
