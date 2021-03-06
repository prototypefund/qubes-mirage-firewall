(* Copyright (C) 2015, Thomas Leonard <thomas.leonard@unikernel.com>
   See the README file for details. *)

(** Routing packets to the right network interface. *)

open Fw_utils

type t = private {
  client_eth : Client_eth.t;
  nat : My_nat.t;
  uplink : interface;
  dns_sender: int -> (Dns.proto * Ipaddr.V4.t * Cstruct.t) -> unit Lwt.t;
  ports : Ports.PortSet.t ref;
}
(** A routing table. *)
(* t.ports <- Ports.PortSet.add new_port t.ports *)
(* so if someone passes ports to a function, is the type Ports.PortSet.t or Ports.PortSet.t ref ? *)


val create :
  client_eth:Client_eth.t ->
  uplink:interface ->
  dns_sender:(int -> (Dns.proto * Ipaddr.V4.t * Cstruct.t) -> unit Lwt.t) ->
  nat:My_nat.t ->
  t
(** [create ~client_eth ~uplink ~dns_sender] is a new routing table
    that routes packets outside of [client_eth] via [uplink]. *)

val target : t -> Ipv4_packet.t -> interface option
(** [target t packet] is the interface to which [packet] should be routed. *)

val add_client : t -> client_link -> unit Lwt.t
(** [add_client t iface] adds a rule for routing packets addressed to [iface]. *)

val remove_client : t -> client_link -> unit

val classify : t -> Ipaddr.t -> Packet.host
val resolve : t -> Packet.host -> Ipaddr.t
