data "unifi_user_group" "default" {
}
data "unifi_ap_group" "default" {
}

/* Nasreddine */

resource "secret_resource" "wlan-nasreddine" {
  lifecycle {
    # avoid accidentally loosing the secret
    prevent_destroy = true
  }
}

resource "unifi_wlan" "nasreddine" {
  name = "Nasreddine"

  ap_group_ids  = [data.unifi_ap_group.default.id]
  network_id    = unifi_network.general.id
  passphrase    = secret_resource.wlan-nasreddine.value
  security      = "wpapsk"
  user_group_id = data.unifi_user_group.default.id
}

/* Nasreddine-ADMIN */

resource "secret_resource" "wlan-nasreddine-admin" {
  lifecycle {
    # avoid accidentally loosing the secret
    prevent_destroy = true
  }
}

resource "unifi_wlan" "nasreddine-admin" {
  name = "Nasreddine-ADMIN"

  ap_group_ids  = [data.unifi_ap_group.default.id]
  hide_ssid     = true
  network_id    = unifi_network.admin.id
  passphrase    = secret_resource.wlan-nasreddine-admin.value
  security      = "wpapsk"
  user_group_id = data.unifi_user_group.default.id
}

/* Nasreddine-Guest */

resource "secret_resource" "wlan-nasreddine-guest" {
  lifecycle {
    # avoid accidentally loosing the secret
    prevent_destroy = true
  }
}

resource "unifi_wlan" "nasreddine-guest" {
  name = "Nasreddine-Guest"

  ap_group_ids  = [data.unifi_ap_group.default.id]
  network_id    = unifi_network.guest_0.id
  passphrase    = secret_resource.wlan-nasreddine-guest.value
  security      = "wpapsk"
  user_group_id = data.unifi_user_group.default.id
}
