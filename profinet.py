import socket
import struct
import subprocess
import select

DEVICE_NAME = "raspi-profinet-device"
DEVICE_IP   = "192.168.1.10"
INTERFACE   = "eth0"

def setup_network():
    subprocess.run(["ip", "addr", "flush", "dev", INTERFACE],
                   capture_output=True)
    subprocess.run(["ip", "addr", "add", f"{DEVICE_IP}/24", "dev", INTERFACE],
                   capture_output=True)
    subprocess.run(["ip", "link", "set", INTERFACE, "up"],
                   capture_output=True)
    with open(f'/sys/class/net/{INTERFACE}/address', 'r') as f:
        mac_str = f.read().strip()
    mac = bytes.fromhex(mac_str.replace(':', ''))
    print(f"Device  : {DEVICE_NAME}")
    print(f"IP      : {DEVICE_IP}")
    print(f"MAC     : {mac_str}")
    return mac

def pad_even(data):
    return data + b'\x00' if len(data) % 2 else data

def build_identify_response(my_mac, requester_mac, xid):
    blocks = bytearray()

    # Block 1 - NameOfStation
    name       = DEVICE_NAME.encode('ascii')
    name_block = pad_even(bytes([0x00, 0x00]) + name)
    blocks += bytes([0x02, 0x02])
    blocks += struct.pack('!H', len(name_block))
    blocks += name_block

    # Block 2 - IP Address
    ip_block = bytes([
        0x00, 0x01,
        192, 168, 1, 10,
        255, 255, 255, 0,
        192, 168, 1, 1
    ])
    blocks += bytes([0x01, 0x02])
    blocks += struct.pack('!H', len(ip_block))
    blocks += ip_block

    # Block 3 - Device ID
    did_block = bytes([0x00, 0x00, 0x00, 0x2A, 0x00, 0x01])
    blocks += bytes([0x02, 0x03])
    blocks += struct.pack('!H', len(did_block))
    blocks += did_block

    # Block 4 - Device Role (IO Device)
    role_block = bytes([0x00, 0x00, 0x02, 0x00])
    blocks += bytes([0x02, 0x04])
    blocks += struct.pack('!H', len(role_block))
    blocks += role_block

    # Assemble frame
    frame = bytearray()
    frame += requester_mac
    frame += my_mac
    frame += bytes([0x88, 0x92])
    frame += bytes([0xFE, 0xFF])
    frame += bytes([0x05, 0x01])
    frame += xid
    frame += bytes([0x00, 0x00])
    frame += struct.pack('!H', len(blocks))
    frame += blocks

    while len(frame) < 60:
        frame += b'\x00'

    return bytes(frame)

def build_set_response(my_mac, requester_mac, xid):
    frame = bytearray()
    frame += requester_mac
    frame += my_mac
    frame += bytes([0x88, 0x92])
    frame += bytes([0xFE, 0xFD])
    frame += bytes([0x04, 0x01])
    frame += xid
    frame += bytes([0x00, 0x00, 0x00, 0x00])

    while len(frame) < 60:
        frame += b'\x00'

    return bytes(frame)

def main():
    my_mac = setup_network()

    sock = socket.socket(socket.AF_PACKET,
                         socket.SOCK_RAW,
                         socket.htons(0x0003))
    sock.bind((INTERFACE, 0))
    sock.setblocking(False)

    print(f"\nPROFINET device running on {INTERFACE}")
    print(f"Waiting for controller...\n")

    counter = 0

    while True:
        ready = select.select([sock], [], [], 0.01)
        if not ready[0]:
            continue

        try:
            pkt, _ = sock.recvfrom(2048)
        except BlockingIOError:
            continue

        # Filter only PROFINET ethertype 0x8892
        if pkt[12:14] != bytes([0x88, 0x92]):
            continue

        fid     = pkt[14:16]
        src_mac = pkt[6:12]
        xid     = pkt[18:22]

        # DCP Identify Request - FrameID 0xFEFE
        if fid == bytes([0xFE, 0xFE]):
            resp = build_identify_response(my_mac, src_mac, xid)
            sock.send(resp)
            counter += 1
            print(f"DCP Identify Request  -> Response sent"
                  f" #{counter} to {src_mac.hex(':')}")

        # DCP Set Request - FrameID 0xFEFD
        elif fid == bytes([0xFE, 0xFD]):
            resp = build_set_response(my_mac, src_mac, xid)
            sock.send(resp)
            print(f"DCP Set Request       -> Response sent"
                  f" to {src_mac.hex(':')}")

        # Any other PROFINET frame - log it
        else:
            print(f"PROFINET frame        -> FrameID={fid.hex()}"
                  f" from={src_mac.hex(':')}")

if __name__ == "__main__":
    main()
