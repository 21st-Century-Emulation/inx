require "crest"
require "json"
require "kemal"

logging false

# You can use JSON.mapping to directly create an object from JSON
class User
  include JSON::Serializable

  property username : String, password : String
end

class CpuFlags
  include JSON::Serializable

  property sign : Bool, zero : Bool, auxCarry : Bool, parity : Bool, carry : Bool
end

class CpuState
  include JSON::Serializable

  property a : UInt8, b : UInt8, c : UInt8, d : UInt8, e : UInt8, h : UInt8, l : UInt8, stackPointer : UInt16, programCounter : UInt16, cycles : UInt64, flags : CpuFlags, interruptsEnabled : Bool
end

class Cpu
  include JSON::Serializable

  property opcode : UInt8, id : String, state : CpuState
end  

VERSION = "0.1.0"

get "/status" do
  "Healthy"
end

post "/api/v1/execute" do |env|
  cpu = Cpu.from_json env.request.body.not_nil!
  opcode = cpu.opcode
  state = cpu.state

  state.cycles &+= 5
  case opcode
  when 0x03 then # INX B
    bc = (state.b.to_u16 << 8) | state.c.to_u16
    bc &+= 1
    state.b = (bc >> 8).to_u8
    state.c = (bc & 0xFF).to_u8
  when 0x13 then # INX D
    de = (state.d.to_u16 << 8) | state.e.to_u16
    de &+= 1
    state.d = (de >> 8).to_u8
    state.e = (de & 0xFF).to_u8
  when 0x23 then # INX H
    hl = (state.h.to_u16 << 8) | state.l.to_u16
    hl &+= 1
    state.h = (hl >> 8).to_u8
    state.l = (hl & 0xFF).to_u8
  when 0x33 then # INX SP
    state.stackPointer &+= 1
  end

  cpu.to_json
end

Kemal.config.port = 8080
Kemal.run
