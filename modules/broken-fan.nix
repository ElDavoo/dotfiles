# TEMPORANEO: la ventola della CPU è rotta. Tutto quello che serve per tenere
# la CPU sotto ~50 °C (sopra l'EC accende la ventola) sta in questo file:
# quando arriva il ricambio basta togliere l'import da hosts/mattone/default.nix
# e cancellare il file.
#
# Tre livelli, dal più rigido al più dinamico:
#   1. TLP: niente turbo, frequenza massima tagliata, EPP al minimo consumo,
#      iGPU limitata, sia su AC che a batteria;
#   2. RAPL: tetto fisso alla potenza del package (PL1/PL2) a ogni avvio e
#      resume;
#   3. thermald: se nonostante tutto x86_pkg_temp supera la soglia, abbassa
#      ancora RAPL, poi P-state, poi inietta idle (powerclamp).
{pkgs, ...}: let
  # ritocca qui se è troppo lento o scalda ancora troppo
  maxFreqKHz = 1600000; # base 2.3 GHz, turbo 5.1 GHz
  pl1W = 10; # sostenuto (default BIOS: 120 W)
  pl2W = 12; # picchi brevi
  tripMilliC = 45000; # thermald interviene qui, margine sotto i 50 °C

  thermaldConf = pkgs.writeText "thermal-conf.xml" ''
    <?xml version="1.0"?>
    <ThermalConfiguration>
      <Platform>
        <Name>mattone ventola rotta</Name>
        <ProductName>*</ProductName>
        <Preference>QUIET</Preference>
        <ThermalZones>
          <ThermalZone>
            <Type>cpu</Type>
            <TripPoints>
              <TripPoint>
                <SensorType>x86_pkg_temp</SensorType>
                <Temperature>${toString tripMilliC}</Temperature>
                <type>passive</type>
                <ControlType>SEQUENTIAL</ControlType>
                <CoolingDevice>
                  <index>1</index>
                  <type>rapl_controller</type>
                  <influence>100</influence>
                  <SamplingPeriod>2</SamplingPeriod>
                </CoolingDevice>
                <CoolingDevice>
                  <index>2</index>
                  <type>intel_pstate</type>
                  <influence>80</influence>
                  <SamplingPeriod>2</SamplingPeriod>
                </CoolingDevice>
                <CoolingDevice>
                  <index>3</index>
                  <type>intel_powerclamp</type>
                  <influence>60</influence>
                  <SamplingPeriod>2</SamplingPeriod>
                </CoolingDevice>
              </TripPoint>
            </TripPoints>
          </ThermalZone>
        </ThermalZones>
      </Platform>
    </ThermalConfiguration>
  '';
in {
  # si sommano alle impostazioni di power.nix (dove coincidono i valori sono
  # gli stessi), qui valgono anche su AC
  services.tlp.settings = {
    CPU_BOOST_ON_AC = 0;
    CPU_BOOST_ON_BAT = 0;
    CPU_HWP_DYN_BOOST_ON_AC = 0;
    CPU_HWP_DYN_BOOST_ON_BAT = 0;
    CPU_ENERGY_PERF_POLICY_ON_AC = "power";
    CPU_ENERGY_PERF_POLICY_ON_BAT = "power";
    CPU_SCALING_MAX_FREQ_ON_AC = maxFreqKHz;
    CPU_SCALING_MAX_FREQ_ON_BAT = maxFreqKHz;
    INTEL_GPU_MAX_FREQ_ON_AC = 800;
    INTEL_GPU_BOOST_FREQ_ON_AC = 800;
  };

  # i limiti RAPL non persistono e il BIOS li rimette a 120 W al resume.
  # Gira prima di thermald, che prende il PL1 di partenza come massimo.
  systemd.services.broken-fan-power-cap = {
    description = "Package power cap (ventola rotta)";
    wantedBy = ["multi-user.target" "post-resume.target"];
    after = ["post-resume.target"];
    before = ["thermald.service"];
    serviceConfig.Type = "oneshot";
    script = ''
      rapl=/sys/class/powercap/intel-rapl:0
      for c in "$rapl"/constraint_*_name; do
        case "$(cat "$c")" in
          long_term) echo ${toString (pl1W * 1000000)} > "''${c%_name}_power_limit_uw" ;;
          short_term) echo ${toString (pl2W * 1000000)} > "''${c%_name}_power_limit_uw" ;;
        esac
      done
    '';
  };

  services.thermald = {
    enable = true;
    configFile = thermaldConf;
  };
}
