# TEMPORANEO: la ventola della CPU era rotta ed è stata smontata, quindi il
# raffreddamento è solo passivo. Tutto quello che serve per tenere la CPU
# sotto ~65 °C sta in questo file: quando arriva il ricambio basta togliere
# l'import da hosts/mattone/default.nix e cancellare il file.
#
# Frequenze e turbo restano quelli di serie; a limitare sono:
#   1. RAPL: tetto fisso alla potenza del package (PL1/PL2) a ogni avvio e
#      resume;
#   2. thermald: se x86_pkg_temp supera la soglia abbassa PL1, poi P-state,
#      poi inietta idle (powerclamp);
#   3. TLP: iGPU limitata anche su AC.
{pkgs, ...}: let
  # ritocca qui se è troppo lento o scalda ancora troppo
  pl1W = 15; # sostenuto (default BIOS: 120 W)
  pl2W = 20; # picchi brevi
  pl1MinW = 4; # sotto questo thermald passa a P-state e powerclamp
  tripMilliC = 65000; # thermald interviene qui

  thermaldConf = pkgs.writeText "thermal-conf.xml" ''
    <?xml version="1.0"?>
    <ThermalConfiguration>
      <Platform>
        <Name>mattone senza ventola</Name>
        <ProductName>*</ProductName>
        <Preference>QUIET</Preference>
        <!-- senza PPCC il rapl_controller usa come tetto il TDP di targa
             (constraint_0_max_power_uw = 45 W) e scavalca il nostro PL1.
             Valori in mW e ms. -->
        <PPCC>
          <PowerLimitMinimum>${toString (pl1MinW * 1000)}</PowerLimitMinimum>
          <PowerLimitMaximum>${toString (pl1W * 1000)}</PowerLimitMaximum>
          <TimeWindowMinimum>28000</TimeWindowMinimum>
          <TimeWindowMaximum>28000</TimeWindowMaximum>
          <StepSize>500</StepSize>
        </PPCC>
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
  # power.nix la limita solo a batteria
  services.tlp.settings = {
    INTEL_GPU_MAX_FREQ_ON_AC = 800;
    INTEL_GPU_BOOST_FREQ_ON_AC = 800;
  };

  # i limiti RAPL non persistono e il BIOS li rimette a 120 W al resume.
  # thermald riscrive PL1 (fra pl1MinW e pl1W, vedi PPCC) ma non PL2.
  systemd.services.broken-fan-power-cap = {
    description = "Package power cap (senza ventola)";
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
