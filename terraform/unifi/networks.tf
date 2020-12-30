resource "unifi_network" "admin" {
  name    = "Admin"
  purpose = "corporate"

  vlan_id = 2
  subnet  = "192.168.2.0/24"

  domain_name = "admin.nasreddine.com"

  dhcp_dns     = ["192.168.2.5"]
  dhcp_enabled = true
  dhcp_start   = "192.168.2.6"
  dhcp_stop    = "192.168.2.254"

  ipv6_ra_enable = true
}

resource "unifi_network" "general" {
  name    = "General"
  purpose = "corporate"

  subnet = "192.168.10.0/24"

  domain_name = "general.nasreddine.com"

  dhcp_dns     = ["192.168.10.5"]
  dhcp_enabled = true
  dhcp_start   = "192.168.10.6"
  dhcp_stop    = "192.168.10.254"

  ipv6_ra_enable = true
}

resource "unifi_network" "server_network_0" {
  name    = "Server Network 0"
  purpose = "corporate"

  vlan_id = 50
  subnet  = "192.168.50.0/24"

  domain_name = "sn0.nasreddine.com"

  dhcp_enabled = true
  dhcp_start   = "192.168.50.6"
  dhcp_stop    = "192.168.50.254"

  ipv6_ra_enable = true
}

resource "unifi_network" "guest_0" {
  name    = "Guest 0"
  purpose = "corporate"

  vlan_id = 11
  subnet  = "192.168.11.0/24"

  domain_name = "guest0.nasreddine.com"

  network_group = "LAN2"

  dhcp_enabled = true
  dhcp_start   = "192.168.11.6"
  dhcp_stop    = "192.168.11.254"

  ipv6_ra_enable = true
}

resource "unifi_network" "wan" {
  name    = "WAN"
  purpose = "wan"

  # TODO: This is required parameter but should not be set for WAN
  network_group = ""

  dhcp_lease = 0

  wan_networkgroup = "WAN"
  wan_type         = "dhcp"
}

resource "unifi_network" "wan2" {
  name    = "WAN2"
  purpose = "wan"

  # TODO: This is required parameter but should not be set for WAN
  network_group = ""

  dhcp_lease = 0

  wan_networkgroup = "WAN2"
  wan_type         = "dhcp"
}

resource "secret_resource" "home-vpn_x_ipsec_pre_shared_key" {
  lifecycle {
    # avoid accidentally loosing the secret
    prevent_destroy = true
  }
}

data "unifi_radius_profile" "default" {}

# TODO: Enable this once it's available upstream
# resource "unifi_network" "home-vpn" {
#   name                   = "Home VPN"
#   purpose                = "remote-user-vpn"
#   vpn_type               = "l2tp-server"
#   x_ipsec_pre_shared_key = secret_resource.home-vpn_x_ipsec_pre_shared_key.value
#   subnet                 = "192.168.20.1/24"
#   dhcp_start             = "192.168.20.1"
#   dhcp_stop              = "192.168.20.254"
#   radiusprofile_id       = data.unifi_radius_profile.default.id
# }
