#/bin/bash
echo "this is a badway to support hinlink h68k"
echo "say sorry to immortalwrt."
echo "------------ apply uboot --------------"

# 1. Change Makefile

sed -i 's/lyt-t68m/opc-h68k/g' package/boot/uboot-rockchip/Makefile

sed -i 's/LYT T68M/OPC-H68K/g' package/boot/uboot-rockchip/Makefile

sed -i 's/lyt_t68m/hinlink_opc-h68k/g' package/boot/uboot-rockchip/Makefile

# 2. Change patchfile

sed -i 's/lyt-t68m/opc-h68k/g' package/boot/uboot-rockchip/patches/900-arm-add-dts-files.patch

# 3. add dts && dtsi

cat << EOF >> package/boot/uboot-rockchip/src/arch/arm/dts/rk3568-opc-h68k.dts
// SPDX-License-Identifier: GPL-2.0-or-later OR MIT
/*
 * Copyright (c) 2022 AmadeusGhost <amadeus@jmu.edu.cn>
 */

/dts-v1/;

#include "rk3568-opc-h68k.dtsi"

/ {
	model = "Hinlink OPC-H68K";
	compatible = "hinlink,opc-h68k", "rockchip,rk3568";

	aliases {
		ethernet0 = &gmac0;
		ethernet1 = &gmac1;
	};
};

&gmac0 {
	assigned-clocks = <&cru SCLK_GMAC0_RX_TX>, <&cru SCLK_GMAC0>;
	assigned-clock-parents = <&cru SCLK_GMAC0_RGMII_SPEED>;
	assigned-clock-rates = <0>, <125000000>;
	clock_in_out = "output";
	phy-mode = "rgmii-id";
	pinctrl-names = "default";
	pinctrl-0 = <&gmac0_miim
		     &gmac0_tx_bus2
		     &gmac0_rx_bus2
		     &gmac0_rgmii_clk
		     &gmac0_rgmii_bus>;
	snps,reset-gpio = <&gpio2 RK_PD3 GPIO_ACTIVE_LOW>;
	snps,reset-active-low;
	snps,reset-delays-us = <0 20000 100000>;
	tx_delay = <0x3c>;
	rx_delay = <0x2f>;
	phy-handle = <&rgmii_phy0>;
	status = "okay";
};

&gmac1 {
	assigned-clocks = <&cru SCLK_GMAC1_RX_TX>, <&cru SCLK_GMAC1>;
	assigned-clock-parents = <&cru SCLK_GMAC1_RGMII_SPEED>;
	assigned-clock-rates = <0>, <125000000>;
	clock_in_out = "output";
	phy-mode = "rgmii-id";
	pinctrl-names = "default";
	pinctrl-0 = <&gmac1m1_miim
		     &gmac1m1_tx_bus2
		     &gmac1m1_rx_bus2
		     &gmac1m1_rgmii_clk
		     &gmac1m1_rgmii_bus>;
	snps,reset-gpio = <&gpio1 RK_PB0 GPIO_ACTIVE_LOW>;
	snps,reset-active-low;
	snps,reset-delays-us = <0 20000 100000>;
	tx_delay = <0x4f>;
	rx_delay = <0x26>;
	phy-handle = <&rgmii_phy1>;
	status = "okay";
};

&mdio0 {
	rgmii_phy0: ethernet-phy@0 {
		compatible = "ethernet-phy-ieee802.3-c22";
		reg = <0x0>;
	};
};

&mdio1 {
	rgmii_phy1: ethernet-phy@0 {
		compatible = "ethernet-phy-ieee802.3-c22";
		reg = <0x0>;
	};
};

&vcc3v3_pcie {
	gpio = <&gpio2 RK_PD2 GPIO_ACTIVE_HIGH>;
};

EOF

cat << EOF >> package/boot/uboot-rockchip/src/arch/arm/dts/rk3568-opc-h68k.dtsi
// SPDX-License-Identifier: GPL-2.0-or-later OR MIT
/*
 * Copyright (c) 2022 AmadeusGhost <amadeus@jmu.edu.cn>
 */

#include <dt-bindings/gpio/gpio.h>
#include <dt-bindings/input/input.h>
#include <dt-bindings/pinctrl/rockchip.h>
#include <dt-bindings/soc/rockchip,vop2.h>
#include "rk3568.dtsi"

/ {
	aliases {
		mmc0 = &sdhci;
		mmc1 = &sdmmc0;

		led-boot = &power_led;
		led-failsafe = &power_led;
		led-running = &power_led;
		led-upgrade = &power_led;
	};

	chosen {
		stdout-path = "serial2:1500000n8";
	};

	hdmi-con {
		compatible = "hdmi-connector";
		type = "a";

		port {
			hdmi_con_in: endpoint {
				remote-endpoint = <&hdmi_out_con>;
			};
		};
	};

	gpio-keys {
		compatible = "gpio-keys";
		pinctrl-0 = <&reset_button_pin>;
		pinctrl-names = "default";

		reset {
			label = "reset";
			gpios = <&gpio0 RK_PA0 GPIO_ACTIVE_LOW>;
			linux,code = <KEY_RESTART>;
			debounce-interval = <50>;
		};
	};

	gpio-leds {
		compatible = "gpio-leds";
		pinctrl-names = "default";
		pinctrl-0 = <&led_lan_pin>, <&led_power_pin>, <&led_wan_pin>;

		led-lan {
			label = "amber:lan";
			gpios = <&gpio3 RK_PA7 GPIO_ACTIVE_HIGH>;
		};

		power_led: led-power {
			label = "green:power";
			gpios = <&gpio3 RK_PB0 GPIO_ACTIVE_HIGH>;
		};

		led-wan {
			label = "blue:wan";
			gpios = <&gpio3 RK_PA5 GPIO_ACTIVE_HIGH>;
		};
	};

	pwm-fan {
		compatible = "pwm-fan";
		cooling-levels = <0 100 150 200 255>;
		#cooling-cells = <2>;
		pwms = <&pwm0 0 50000 0>;
	};

	vcc12v_dcin: vcc12v-dcin-regulator {
		compatible = "regulator-fixed";
		regulator-always-on;
		regulator-boot-on;
		regulator-min-microvolt = <12000000>;
		regulator-max-microvolt = <12000000>;
		regulator-name = "vcc12v_dcin";
	};

	vcc3v3_sys: vcc3v3-sys-regulator {
		compatible = "regulator-fixed";
		regulator-always-on;
		regulator-boot-on;
		regulator-min-microvolt = <3300000>;
		regulator-max-microvolt = <3300000>;
		regulator-name = "vcc3v3_sys";
		vin-supply = <&vcc12v_dcin>;
	};

	vcc5v0_sys: vcc5v0-sys-regulator {
		compatible = "regulator-fixed";
		regulator-always-on;
		regulator-boot-on;
		regulator-min-microvolt = <5000000>;
		regulator-max-microvolt = <5000000>;
		regulator-name = "vcc5v0_sys";
		vin-supply = <&vcc12v_dcin>;
	};

	vcc5v0_usb: vcc5v0-usb-regulator {
		compatible = "regulator-fixed";
		regulator-always-on;
		regulator-boot-on;
		regulator-min-microvolt = <5000000>;
		regulator-max-microvolt = <5000000>;
		regulator-name = "vcc5v0_usb";
		vin-supply = <&vcc12v_dcin>;
	};

	vcc5v0_usb_host: vcc5v0-usb-host-regulator {
		compatible = "regulator-fixed";
		enable-active-high;
		gpio = <&gpio0 RK_PA5 GPIO_ACTIVE_HIGH>;
		pinctrl-names = "default";
		pinctrl-0 = <&vcc5v0_usb_host_en>;
		regulator-min-microvolt = <5000000>;
		regulator-max-microvolt = <5000000>;
		regulator-name = "vcc5v0_usb_host";
		vin-supply = <&vcc5v0_usb>;
	};

	vcc3v3_pcie: vcc3v3-pcie-regulator {
		compatible = "regulator-fixed";
		enable-active-high;
		regulator-min-microvolt = <3300000>;
		regulator-max-microvolt = <3300000>;
		regulator-name = "vcc3v3_pcie";
		startup-delay-us = <5000>;
		vin-supply = <&vcc5v0_sys>;
	};
};

&combphy0 {
	status = "okay";
};

&combphy1 {
	status = "okay";
};

&combphy2 {
	status = "okay";
};

&cpu0 {
	cpu-supply = <&vdd_cpu>;
};

&cpu1 {
	cpu-supply = <&vdd_cpu>;
};

&cpu2 {
	cpu-supply = <&vdd_cpu>;
};

&cpu3 {
	cpu-supply = <&vdd_cpu>;
};

&gpu {
	mali-supply = <&vdd_gpu>;
	status = "okay";
};

&hdmi {
	avdd-0v9-supply = <&vdda0v9_image>;
	avdd-1v8-supply = <&vcca1v8_image>;
	status = "okay";
};

&hdmi_in {
	hdmi_in_vp0: endpoint {
		remote-endpoint = <&vp0_out_hdmi>;
	};
};

&hdmi_out {
	hdmi_out_con: endpoint {
		remote-endpoint = <&hdmi_con_in>;
	};
};

&hdmi_sound {
	status = "okay";
};

&i2c0 {
	status = "okay";

	vdd_cpu: regulator@1c {
		compatible = "tcs,tcs4525";
		reg = <0x1c>;
		fcs,suspend-voltage-selector = <1>;
		regulator-name = "vdd_cpu";
		regulator-always-on;
		regulator-boot-on;
		regulator-min-microvolt = <712500>;
		regulator-max-microvolt = <1390000>;
		regulator-ramp-delay = <2300>;
		vin-supply = <&vcc5v0_sys>;

		regulator-state-mem {
			regulator-off-in-suspend;
		};
	};

	rk809: pmic@20 {
		compatible = "rockchip,rk809";
		reg = <0x20>;
		interrupt-parent = <&gpio0>;
		interrupts = <RK_PA3 IRQ_TYPE_LEVEL_LOW>;
		assigned-clocks = <&cru I2S1_MCLKOUT_TX>;
		assigned-clock-parents = <&cru CLK_I2S1_8CH_TX>;
		#clock-cells = <1>;
		clock-names = "mclk";
		clocks = <&cru I2S1_MCLKOUT_TX>;
		pinctrl-names = "default";
		pinctrl-0 = <&pmic_int>, <&i2s1m0_mclk>;
		rockchip,system-power-controller;
		#sound-dai-cells = <0>;
		wakeup-source;

		vcc1-supply = <&vcc3v3_sys>;
		vcc2-supply = <&vcc3v3_sys>;
		vcc3-supply = <&vcc3v3_sys>;
		vcc4-supply = <&vcc3v3_sys>;
		vcc5-supply = <&vcc3v3_sys>;
		vcc6-supply = <&vcc3v3_sys>;
		vcc7-supply = <&vcc3v3_sys>;
		vcc8-supply = <&vcc3v3_sys>;
		vcc9-supply = <&vcc3v3_sys>;

		regulators {
			vdd_logic: DCDC_REG1 {
				regulator-always-on;
				regulator-boot-on;
				regulator-init-microvolt = <900000>;
				regulator-initial-mode = <0x2>;
				regulator-min-microvolt = <500000>;
				regulator-max-microvolt = <1350000>;
				regulator-name = "vdd_logic";
				regulator-ramp-delay = <6001>;

				regulator-state-mem {
					regulator-off-in-suspend;
				};
			};

			vdd_gpu: DCDC_REG2 {
				regulator-always-on;
				regulator-init-microvolt = <900000>;
				regulator-initial-mode = <0x2>;
				regulator-min-microvolt = <500000>;
				regulator-max-microvolt = <1350000>;
				regulator-name = "vdd_gpu";
				regulator-ramp-delay = <6001>;

				regulator-state-mem {
					regulator-off-in-suspend;
				};
			};

			vcc_ddr: DCDC_REG3 {
				regulator-always-on;
				regulator-boot-on;
				regulator-initial-mode = <0x2>;
				regulator-name = "vcc_ddr";

				regulator-state-mem {
					regulator-on-in-suspend;
				};
			};

			vdd_npu: DCDC_REG4 {
				regulator-init-microvolt = <900000>;
				regulator-initial-mode = <0x2>;
				regulator-min-microvolt = <500000>;
				regulator-max-microvolt = <1350000>;
				regulator-name = "vdd_npu";
				regulator-ramp-delay = <6001>;

				regulator-state-mem {
					regulator-off-in-suspend;
				};
			};

			vcc_1v8: DCDC_REG5 {
				regulator-always-on;
				regulator-boot-on;
				regulator-min-microvolt = <1800000>;
				regulator-max-microvolt = <1800000>;
				regulator-name = "vcc_1v8";

				regulator-state-mem {
					regulator-off-in-suspend;
				};
			};

			vdda0v9_image: LDO_REG1 {
				regulator-name = "vdda0v9_image";
				regulator-min-microvolt = <900000>;
				regulator-max-microvolt = <900000>;

				regulator-state-mem {
					regulator-off-in-suspend;
				};
			};

			vdda_0v9: LDO_REG2 {
				regulator-always-on;
				regulator-boot-on;
				regulator-min-microvolt = <900000>;
				regulator-max-microvolt = <900000>;
				regulator-name = "vdda_0v9";

				regulator-state-mem {
					regulator-off-in-suspend;
				};
			};

			vdda0v9_pmu: LDO_REG3 {
				regulator-always-on;
				regulator-boot-on;
				regulator-min-microvolt = <900000>;
				regulator-max-microvolt = <900000>;
				regulator-name = "vdda0v9_pmu";

				regulator-state-mem {
					regulator-on-in-suspend;
					regulator-suspend-microvolt = <900000>;
				};
			};

			vccio_acodec: LDO_REG4 {
				regulator-min-microvolt = <3300000>;
				regulator-max-microvolt = <3300000>;
				regulator-name = "vccio_acodec";

				regulator-state-mem {
					regulator-off-in-suspend;
				};
			};

			vccio_sd: LDO_REG5 {
				regulator-min-microvolt = <1800000>;
				regulator-max-microvolt = <3300000>;
				regulator-name = "vccio_sd";

				regulator-state-mem {
					regulator-off-in-suspend;
				};
			};

			vcc3v3_pmu: LDO_REG6 {
				regulator-always-on;
				regulator-boot-on;
				regulator-min-microvolt = <3300000>;
				regulator-max-microvolt = <3300000>;
				regulator-name = "vcc3v3_pmu";

				regulator-state-mem {
					regulator-on-in-suspend;
					regulator-suspend-microvolt = <3300000>;
				};
			};

			vcca_1v8: LDO_REG7 {
				regulator-always-on;
				regulator-boot-on;
				regulator-min-microvolt = <1800000>;
				regulator-max-microvolt = <1800000>;
				regulator-name = "vcca_1v8";

				regulator-state-mem {
					regulator-off-in-suspend;
				};
			};

			vcca1v8_pmu: LDO_REG8 {
				regulator-always-on;
				regulator-boot-on;
				regulator-min-microvolt = <1800000>;
				regulator-max-microvolt = <1800000>;
				regulator-name = "vcca1v8_pmu";

				regulator-state-mem {
					regulator-on-in-suspend;
					regulator-suspend-microvolt = <1800000>;
				};
			};

			vcca1v8_image: LDO_REG9 {
				regulator-min-microvolt = <1800000>;
				regulator-max-microvolt = <1800000>;
				regulator-name = "vcca1v8_image";

				regulator-state-mem {
					regulator-off-in-suspend;
				};
			};

			vcc_3v3: SWITCH_REG1 {
				regulator-name = "vcc_3v3";
				regulator-always-on;
				regulator-boot-on;

				regulator-state-mem {
					regulator-off-in-suspend;
				};
			};

			vcc3v3_sd: SWITCH_REG2 {
				regulator-name = "vcc3v3_sd";

				regulator-state-mem {
					regulator-off-in-suspend;
				};
			};
		};
	};
};

&i2c5 {
	status = "okay";
};

&i2s0_8ch {
	status = "okay";
};

&pcie2x1 {
	reset-gpios = <&gpio2 RK_PD6 GPIO_ACTIVE_HIGH>;
	vpcie3v3-supply = <&vcc3v3_pcie>;
	status = "okay";
};

&pcie30phy {
	data-lanes = <1 2>;
	status = "okay";
};

&pcie3x1 {
	num-lanes = <1>;
	reset-gpios = <&gpio3 RK_PA4 GPIO_ACTIVE_HIGH>;
	vpcie3v3-supply = <&vcc3v3_pcie>;
	status = "okay";
};

&pcie3x2 {
	num-lanes = <1>;
	reset-gpios = <&gpio2 RK_PD0 GPIO_ACTIVE_HIGH>;
	vpcie3v3-supply = <&vcc3v3_pcie>;
	status = "okay";
};

&pinctrl {
	leds {
		led_lan_pin: led-lan-pin {
			rockchip,pins = <3 RK_PB0 RK_FUNC_GPIO &pcfg_pull_none>;
		};

		led_power_pin: led-power-pin {
			rockchip,pins = <3 RK_PA7 RK_FUNC_GPIO &pcfg_pull_none>;
		};

		led_wan_pin: led-wan-pin {
			rockchip,pins = <3 RK_PA5 RK_FUNC_GPIO &pcfg_pull_none>;
		};
	};

	pmic {
		pmic_int: pmic-int {
			rockchip,pins = <0 RK_PA3 RK_FUNC_GPIO &pcfg_pull_up>;
		};
	};

	rockchip-key {
		reset_button_pin: reset-button-pin {
			rockchip,pins = <0 RK_PA0 RK_FUNC_GPIO &pcfg_pull_up>;
		};
	};

	usb {
		vcc5v0_usb_host_en: vcc5v0-usb-host-en {
			rockchip,pins = <0 RK_PA5 RK_FUNC_GPIO &pcfg_pull_none>;
		};
	};
};

&pmu_io_domains {
	pmuio1-supply = <&vcc3v3_pmu>;
	pmuio2-supply = <&vcc3v3_pmu>;
	vccio1-supply = <&vccio_acodec>;
	vccio2-supply = <&vcc_1v8>;
	vccio3-supply = <&vccio_sd>;
	vccio4-supply = <&vcc_1v8>;
	vccio5-supply = <&vcc_3v3>;
	vccio6-supply = <&vcc_1v8>;
	vccio7-supply = <&vcc_3v3>;
	status = "okay";
};

&pwm0 {
	status = "okay";
};

&saradc {
	vref-supply = <&vcca_1v8>;
	status = "okay";
};

&sata0 {
	status = "okay";
};

&sdhci {
	bus-width = <8>;
	cap-mmc-highspeed;
	max-frequency = <200000000>;
	mmc-hs200-1_8v;
	no-sdio;
	no-sd;
	non-removable;
	pinctrl-names = "default";
	pinctrl-0 = <&emmc_bus8 &emmc_clk &emmc_cmd &emmc_datastrobe>;
	status = "okay";
};

&sdmmc0 {
	bus-width = <4>;
	cap-sd-highspeed;
	cd-gpios = <&gpio0 RK_PA4 GPIO_ACTIVE_LOW>;
	disable-wp;
	pinctrl-names = "default";
	pinctrl-0 = <&sdmmc0_bus4 &sdmmc0_clk &sdmmc0_cmd &sdmmc0_det>;
	sd-uhs-sdr50;
	vmmc-supply = <&vcc3v3_sd>;
	vqmmc-supply = <&vccio_sd>;
	status = "okay";
};

&tsadc {
	rockchip,hw-tshut-mode = <1>;
	rockchip,hw-tshut-polarity = <0>;
	status = "okay";
};

&uart2 {
	status = "okay";
};

&usb_host0_ehci {
	status = "okay";
};

&usb_host0_ohci {
	status = "okay";
};

&usb_host1_ehci {
	status = "okay";
};

&usb_host1_ohci {
	status = "okay";
};

&usb_host1_xhci {
	status = "okay";
};

&usb2phy0 {
	status = "okay";
};

&usb2phy0_host {
	phy-supply = <&vcc5v0_usb_host>;
	status = "okay";
};

&usb2phy1 {
	status = "okay";
};

&usb2phy1_host {
	phy-supply = <&vcc5v0_usb_host>;
	status = "okay";
};

&usb2phy1_otg {
	phy-supply = <&vcc5v0_usb_host>;
	status = "okay";
};

&vop {
	assigned-clocks = <&cru DCLK_VOP0>, <&cru DCLK_VOP1>;
	assigned-clock-parents = <&pmucru PLL_HPLL>, <&cru PLL_VPLL>;
	status = "okay";
};

&vop_mmu {
	status = "okay";
};

&vp0 {
	vp0_out_hdmi: endpoint@ROCKCHIP_VOP2_EP_HDMI0 {
		reg = <ROCKCHIP_VOP2_EP_HDMI0>;
		remote-endpoint = <&hdmi_in_vp0>;
	};
};

EOF

cat << EOF >> package/boot/uboot-rockchip/src/arch/arm/dts/rk3568-opc-h68k-u-boot.dtsi
// SPDX-License-Identifier: GPL-2.0-or-later OR MIT

#include "rk356x-u-boot.dtsi"

/ {
	chosen {
		stdout-path = &uart2;
		u-boot,spl-boot-order = "same-as-spl", &sdhci;
	};
};

&sdhci {
	cap-mmc-highspeed;
	mmc-hs200-1_8v;
};

&uart2 {
	clock-frequency = <24000000>;
	bootph-all;
	status = "okay";
};

EOF

# 4. add deconfig
cat << EOF >> package/boot/uboot-rockchip/src/configs/opc-h68k-rk3568_defconfig
CONFIG_ARM=y
CONFIG_SKIP_LOWLEVEL_INIT=y
CONFIG_COUNTER_FREQUENCY=24000000
CONFIG_ARCH_ROCKCHIP=y
CONFIG_TEXT_BASE=0x00a00000
CONFIG_SPL_LIBCOMMON_SUPPORT=y
CONFIG_SPL_LIBGENERIC_SUPPORT=y
CONFIG_NR_DRAM_BANKS=2
CONFIG_HAS_CUSTOM_SYS_INIT_SP_ADDR=y
CONFIG_CUSTOM_SYS_INIT_SP_ADDR=0xc00000
CONFIG_DEFAULT_DEVICE_TREE="rk3568-opc-h68k"
CONFIG_ROCKCHIP_RK3568=y
CONFIG_SPL_ROCKCHIP_COMMON_BOARD=y
CONFIG_SPL_SERIAL=y
CONFIG_SPL_STACK_R_ADDR=0x600000
CONFIG_TARGET_EVB_RK3568=y
CONFIG_SPL_STACK=0x400000
CONFIG_DEBUG_UART_BASE=0xFE660000
CONFIG_DEBUG_UART_CLOCK=24000000
CONFIG_SYS_LOAD_ADDR=0xc00800
CONFIG_DEBUG_UART=y
CONFIG_FIT=y
CONFIG_FIT_VERBOSE=y
CONFIG_SPL_LOAD_FIT=y
CONFIG_DEFAULT_FDT_FILE="rockchip/rk3568-opc-h68k.dtb"
# CONFIG_DISPLAY_CPUINFO is not set
CONFIG_DISPLAY_BOARDINFO_LATE=y
CONFIG_SPL_MAX_SIZE=0x40000
CONFIG_SPL_PAD_TO=0x7f8000
CONFIG_SPL_HAS_BSS_LINKER_SECTION=y
CONFIG_SPL_BSS_START_ADDR=0x4000000
CONFIG_SPL_BSS_MAX_SIZE=0x4000
# CONFIG_SPL_RAW_IMAGE_SUPPORT is not set
# CONFIG_SPL_SHARES_INIT_SP_ADDR is not set
CONFIG_SPL_STACK_R=y
CONFIG_SPL_ATF=y
CONFIG_CMD_GPIO=y
CONFIG_CMD_GPT=y
CONFIG_CMD_I2C=y
CONFIG_CMD_MMC=y
CONFIG_CMD_USB=y
CONFIG_CMD_PMIC=y
CONFIG_CMD_REGULATOR=y
# CONFIG_SPL_DOS_PARTITION is not set
CONFIG_SPL_OF_CONTROL=y
CONFIG_OF_LIVE=y
CONFIG_OF_SPL_REMOVE_PROPS="pinctrl-0 pinctrl-names clock-names interrupt-parent assigned-clocks assigned-clock-rates assigned-clock-parents"
CONFIG_SPL_DM_WARN=y
CONFIG_SPL_REGMAP=y
CONFIG_SPL_SYSCON=y
CONFIG_SPL_CLK=y
CONFIG_ROCKCHIP_GPIO=y
CONFIG_SYS_I2C_ROCKCHIP=y
CONFIG_MISC=y
CONFIG_SUPPORT_EMMC_RPMB=y
CONFIG_MMC_DW=y
CONFIG_MMC_DW_ROCKCHIP=y
CONFIG_MMC_SDHCI=y
CONFIG_MMC_SDHCI_SDMA=y
CONFIG_MMC_SDHCI_ROCKCHIP=y
CONFIG_ETH_DESIGNWARE=y
CONFIG_GMAC_ROCKCHIP=y
CONFIG_PHY_ROCKCHIP_INNO_USB2=y
CONFIG_PHY_ROCKCHIP_NANENG_COMBOPHY=y
CONFIG_POWER_DOMAIN=y
CONFIG_DM_PMIC=y
CONFIG_PMIC_RK8XX=y
CONFIG_SPL_DM_REGULATOR_FIXED=y
CONFIG_REGULATOR_RK8XX=y
CONFIG_PWM_ROCKCHIP=y
CONFIG_SPL_RAM=y
CONFIG_BAUDRATE=1500000
CONFIG_DEBUG_UART_SHIFT=2
CONFIG_SYS_NS16550_MEM32=y
CONFIG_SYSRESET=y
CONFIG_SYSRESET_PSCI=y
CONFIG_USB=y
CONFIG_USB_XHCI_HCD=y
CONFIG_USB_XHCI_DWC3=y
CONFIG_USB_EHCI_HCD=y
CONFIG_USB_EHCI_GENERIC=y
CONFIG_USB_OHCI_HCD=y
CONFIG_USB_OHCI_GENERIC=y
CONFIG_USB_DWC3=y
CONFIG_ERRNO_STR=y

EOF
echo "------------TARGET ---------------"

# 1. change led
sed -i '/esac/i \hinlink,opc-h68k)\n\tucidef_set_led_netdev "wan" "WAN" "blue:net" "eth2"\n\t;;' target/linux/rockchip/armv8/base-files/etc/board.d/01_leds

# 2. change network
sed -i '/lyt/i \\thinlink,opc-h68k)\n\t\tucidef_set_interfaces_lan_wan "eth0 eth1 eth3" "eth2"\n\t\t;;' target/linux/rockchip/armv8/base-files/etc/board.d/02_network
sed -i '0,/armsom,sige3|\\/!{0,/armsom,sige3|\\/s//armsom,sige3|\\\n\thinlink,opc-h68k|\\/}' target/linux/rockchip/armv8/base-files/etc/board.d/02_network

# 3. change net-smp-affinity

sed -i '/esac/d ' target/linux/rockchip/armv8/base-files/etc/hotplug.d/net/40-net-smp-affinity
cat << EOF >> target/linux/rockchip/armv8/base-files/etc/hotplug.d/net/40-net-smp-affinity
hinlink,opc-h68k)
	set_interface_core "0-3" "eth0"
	set_interface_core "1" "eth1"
	set_interface_core "2" "eth2-0"
	set_interface_core "2" "eth2-16"
	set_interface_core "1" "eth2-18"
	set_interface_core "3" "eth3-0"
	set_interface_core "3" "eth3-18"
	set_interface_core "1" "eth3-16"
	rfc=32768
	sysctl net.core.rps_sock_flow_entries=\$rfc
	for fileRfc in \$(ls /sys/class/net/eth*/queues/rx-*/rps_flow_cnt)
	do
		eth_name=\$(echo "\$fileRfc"|awk -F/ '{print \$5}')
		echo \$rfc > \$fileRfc
	done
	#0101
	echo 9 > /sys/class/net/eth0/queues/rx-0/rps_cpus
	echo 9 > /sys/class/net/eth1/queues/rx-0/rps_cpus
	#0011
	echo 3 > /sys/class/net/eth2/queues/rx-0/rps_cpus
	echo 3 > /sys/class/net/eth2/queues/rx-1/rps_cpus
	#1100
	echo c > /sys/class/net/eth3/queues/rx-0/rps_cpus
	echo c > /sys/class/net/eth3/queues/rx-1/rps_cpus
	/usr/sbin/ethtool -K eth0 tso on sg on tx on
	/usr/sbin/ethtool -K eth1 tso on sg on tx on
	/usr/sbin/ethtool -K eth2 tso on sg on tx on
	/usr/sbin/ethtool -K eth3 tso on sg on tx on
	;;
esac
EOF

# 4.add dts & dtsi

cat << EOF >> target/linux/rockchip/files/arch/arm64/boot/dts/rockchip/rk3568-opc-h68k.dts
// SPDX-License-Identifier: (GPL-2.0+ OR MIT)
// Copyright (c) 2022 AmadeusGhost <amadeus@jmu.edu.cn>

/dts-v1/;

#include "rk3568-opc-h68k.dtsi"

/ {
	model = "HINLINK OPC-H68K Board";
	compatible = "hinlink,opc-h68k", "rockchip,rk3568";

	aliases {
		ethernet0 = &gmac0;
		ethernet1 = &gmac1;
	};
};

&gmac0 {
        phy-mode = "rgmii";
        clock_in_out = "output";
        snps,reset-gpio = <&gpio2 RK_PD3 GPIO_ACTIVE_LOW>;
        snps,reset-active-low;
        snps,reset-delays-us = <0 20000 100000>;
        assigned-clocks = <&cru SCLK_GMAC0_RX_TX>, <&cru SCLK_GMAC0>;
        assigned-clock-parents = <&cru SCLK_GMAC0_RGMII_SPEED>, <&cru CLK_MAC0_2TOP>;
        assigned-clock-rates = <0>, <125000000>;
        pinctrl-names = "default";
        pinctrl-0 = <&gmac0_miim
                 &gmac0_tx_bus2
                 &gmac0_rx_bus2
                 &gmac0_rgmii_clk
                 &gmac0_rgmii_bus>;
        tx_delay = <0x19>;
        rx_delay = <0x10>;
        phy-handle = <&rgmii_phy0>;
        status = "okay";
};

&gmac1 {
        phy-mode = "rgmii";
        clock_in_out = "output";
        snps,reset-gpio = <&gpio1 RK_PB0 GPIO_ACTIVE_LOW>;
        snps,reset-active-low;
        snps,reset-delays-us = <0 20000 100000>;
        assigned-clocks = <&cru SCLK_GMAC1_RX_TX>, <&cru SCLK_GMAC1>;
        assigned-clock-parents = <&cru SCLK_GMAC1_RGMII_SPEED>, <&cru CLK_MAC1_2TOP>;
        assigned-clock-rates = <0>, <125000000>;
        pinctrl-names = "default";
        pinctrl-0 = <&gmac1m1_miim
                 &gmac1m1_tx_bus2
                 &gmac1m1_rx_bus2
                 &gmac1m1_rgmii_clk
                 &gmac1m1_rgmii_bus>;
	    tx_delay = <0x4f>;
	    rx_delay = <0x26>;
        phy-handle = <&rgmii_phy1>;
        status = "okay";
};

&mdio0 {
	rgmii_phy0: phy@0 {
		compatible = "ethernet-phy-id001c.c916",
			     "ethernet-phy-ieee802.3-c22";
		reg = <0x0>;
	};
};

&mdio1 {
	rgmii_phy1: phy@0 {
		compatible = "ethernet-phy-id001c.c916",
			     "ethernet-phy-ieee802.3-c22";
		reg = <0x0>;
	};
};

&vcc3v3_pcie {
	gpio = <&gpio2 RK_PD2 GPIO_ACTIVE_HIGH>;
};

EOF

cat << EOF >> target/linux/rockchip/files/arch/arm64/boot/dts/rockchip/rk3568-opc-h68k.dtsi
// SPDX-License-Identifier: (GPL-2.0+ OR MIT)
// Copyright (c) 2022 AmadeusGhost <amadeus@jmu.edu.cn>

/dts-v1/;
#include <dt-bindings/gpio/gpio.h>
#include <dt-bindings/pwm/pwm.h>
#include <dt-bindings/leds/common.h>
#include <dt-bindings/input/input.h>
#include <dt-bindings/pinctrl/rockchip.h>
#include <dt-bindings/soc/rockchip,vop2.h>
#include "rk3568.dtsi"

/ {
	aliases {
		mmc0 = &sdmmc0;
		mmc1 = &sdhci;

		led-boot = &led_work;
		led-failsafe = &led_work;
		led-running = &led_work;
		led-upgrade = &led_work;
	};

	chosen {
		stdout-path = "serial2:1500000n8";
	};

	hdmi-con {
		compatible = "hdmi-connector";
		type = "a";

		port {
			hdmi_con_in: endpoint {
				remote-endpoint = <&hdmi_out_con>;
			};
		};
	};

	pwm-fan {
		compatible = "pwm-fan";
		cooling-levels = <0 100 150 200 255>;
		#cooling-cells = <2>;
		pwms = <&pwm0 0 50000 0>;
		rockchip,temp-trips = <
			50000	1
			55000	2
			60000	3
			65000	4
		>;
	};

	keys {
		compatible = "gpio-keys";
		pinctrl-0 = <&reset_button_pin>;
		pinctrl-names = "default";

		reset {
			label = "reset";
			gpios = <&gpio0 RK_PA0 GPIO_ACTIVE_LOW>;
			linux,code = <KEY_RESTART>;
			debounce-interval = <50>;
		};
	};

	leds {
		compatible = "gpio-leds";
		pinctrl-names = "default";
		pinctrl-0 = <&led_net_en>, <&led_sata_en>, <&led_work_en>;

		net {
			label = "blue:net";
			gpios = <&gpio3 RK_PA5 GPIO_ACTIVE_HIGH>;
		};

		sata {
			label = "amber:sata";
			gpios = <&gpio3 RK_PA7 GPIO_ACTIVE_HIGH>;
		};

		led_work: work {
			label = "green:work";
			gpios = <&gpio3 RK_PB0 GPIO_ACTIVE_HIGH>;
		};
	};

	vcc12v_dcin: vcc12v-dcin {
		compatible = "regulator-fixed";
		regulator-always-on;
		regulator-boot-on;
		regulator-min-microvolt = <12000000>;
		regulator-max-microvolt = <12000000>;
		regulator-name = "vcc12v_dcin";
	};

	vcc3v3_sys: vcc3v3-sys {
		compatible = "regulator-fixed";
		regulator-always-on;
		regulator-boot-on;
		regulator-min-microvolt = <3300000>;
		regulator-max-microvolt = <3300000>;
		regulator-name = "vcc3v3_sys";
		vin-supply = <&vcc12v_dcin>;
	};

	vcc5v0_sys: vcc5v0-sys {
		compatible = "regulator-fixed";
		regulator-always-on;
		regulator-boot-on;
		regulator-min-microvolt = <5000000>;
		regulator-max-microvolt = <5000000>;
		regulator-name = "vcc5v0_sys";
		vin-supply = <&vcc12v_dcin>;
	};

	vcc5v0_usb: vcc5v0-usb {
		compatible = "regulator-fixed";
		regulator-always-on;
		regulator-boot-on;
		regulator-min-microvolt = <5000000>;
		regulator-max-microvolt = <5000000>;
		regulator-name = "vcc5v0_usb";
		vin-supply = <&vcc12v_dcin>;
	};

	vcc5v0_usb_host: vcc5v0-usb-host {
		compatible = "regulator-fixed";
		enable-active-high;
		gpio = <&gpio0 RK_PA5 GPIO_ACTIVE_HIGH>;
		pinctrl-names = "default";
		pinctrl-0 = <&vcc5v0_usb_host_en>;
		regulator-min-microvolt = <5000000>;
		regulator-max-microvolt = <5000000>;
		regulator-name = "vcc5v0_usb_host";
		vin-supply = <&vcc5v0_usb>;
	};

	vcc3v3_pcie: gpio-regulator {
		compatible = "regulator-fixed";
		regulator-name = "vcc3v3_pcie";
		regulator-min-microvolt = <3300000>;
		regulator-max-microvolt = <3300000>;
		enable-active-high;
		startup-delay-us = <5000>;
		vin-supply = <&vcc5v0_sys>;
	};

	rk809-sound {
		compatible = "simple-audio-card";
		simple-audio-card,format = "i2s";
		simple-audio-card,name = "Analog RK809";
		simple-audio-card,mclk-fs = <256>;

		simple-audio-card,cpu {
			sound-dai = <&i2s1_8ch>;
		};
		simple-audio-card,codec {
			sound-dai = <&rk809>;
		};
	};
};

&combphy0 {
	status = "okay";
};

&combphy1 {
	status = "okay";
};

&combphy2 {
	status = "okay";
};

&cpu0 {
	cpu-supply = <&vdd_cpu>;
};

&cpu1 {
	cpu-supply = <&vdd_cpu>;
};

&cpu2 {
	cpu-supply = <&vdd_cpu>;
};

&cpu3 {
	cpu-supply = <&vdd_cpu>;
};

&gpu {
	mali-supply = <&vdd_gpu>;
	status = "okay";
};

&hdmi {
	avdd-0v9-supply = <&vdda0v9_image>;
	avdd-1v8-supply = <&vcca1v8_image>;
	status = "okay";
};

&hdmi_in {
	hdmi_in_vp0: endpoint {
		remote-endpoint = <&vp0_out_hdmi>;
	};
};

&hdmi_out {
	hdmi_out_con: endpoint {
		remote-endpoint = <&hdmi_con_in>;
	};
};

&hdmi_sound {
	status = "okay";
};

&i2c0 {
	status = "okay";

	vdd_cpu: regulator@1c {
		compatible = "tcs,tcs4525";
		reg = <0x1c>;
		fcs,suspend-voltage-selector = <1>;
		regulator-name = "vdd_cpu";
		regulator-always-on;
		regulator-boot-on;
		regulator-min-microvolt = <712500>;
		regulator-max-microvolt = <1390000>;
		regulator-ramp-delay = <2300>;
		vin-supply = <&vcc5v0_sys>;

		regulator-state-mem {
			regulator-off-in-suspend;
		};
	};

	rk809: pmic@20 {
		compatible = "rockchip,rk809";
		reg = <0x20>;
		interrupt-parent = <&gpio0>;
		interrupts = <RK_PA3 IRQ_TYPE_LEVEL_LOW>;
		assigned-clocks = <&cru I2S1_MCLKOUT_TX>;
		assigned-clock-parents = <&cru CLK_I2S1_8CH_TX>;
		#clock-cells = <1>;
		clock-names = "mclk";
		clocks = <&cru I2S1_MCLKOUT_TX>;
		pinctrl-names = "default";
		pinctrl-0 = <&pmic_int>, <&i2s1m0_mclk>;
		rockchip,system-power-controller;
		#sound-dai-cells = <0>;
		wakeup-source;

		vcc1-supply = <&vcc3v3_sys>;
		vcc2-supply = <&vcc3v3_sys>;
		vcc3-supply = <&vcc3v3_sys>;
		vcc4-supply = <&vcc3v3_sys>;
		vcc5-supply = <&vcc3v3_sys>;
		vcc6-supply = <&vcc3v3_sys>;
		vcc7-supply = <&vcc3v3_sys>;
		vcc8-supply = <&vcc3v3_sys>;
		vcc9-supply = <&vcc3v3_sys>;

		regulators {
			vdd_logic: DCDC_REG1 {
				regulator-always-on;
				regulator-boot-on;
				regulator-init-microvolt = <900000>;
				regulator-initial-mode = <0x2>;
				regulator-min-microvolt = <500000>;
				regulator-max-microvolt = <1350000>;
				regulator-name = "vdd_logic";
				regulator-ramp-delay = <6001>;

				regulator-state-mem {
					regulator-off-in-suspend;
				};
			};

			vdd_gpu: DCDC_REG2 {
				regulator-always-on;
				regulator-init-microvolt = <900000>;
				regulator-initial-mode = <0x2>;
				regulator-min-microvolt = <500000>;
				regulator-max-microvolt = <1350000>;
				regulator-name = "vdd_gpu";
				regulator-ramp-delay = <6001>;

				regulator-state-mem {
					regulator-off-in-suspend;
				};
			};

			vcc_ddr: DCDC_REG3 {
				regulator-always-on;
				regulator-boot-on;
				regulator-initial-mode = <0x2>;
				regulator-name = "vcc_ddr";

				regulator-state-mem {
					regulator-on-in-suspend;
				};
			};

			vdd_npu: DCDC_REG4 {
				regulator-init-microvolt = <900000>;
				regulator-initial-mode = <0x2>;
				regulator-min-microvolt = <500000>;
				regulator-max-microvolt = <1350000>;
				regulator-name = "vdd_npu";
				regulator-ramp-delay = <6001>;

				regulator-state-mem {
					regulator-off-in-suspend;
				};
			};

			vcc_1v8: DCDC_REG5 {
				regulator-always-on;
				regulator-boot-on;
				regulator-min-microvolt = <1800000>;
				regulator-max-microvolt = <1800000>;
				regulator-name = "vcc_1v8";

				regulator-state-mem {
					regulator-off-in-suspend;
				};
			};

			vdda0v9_image: LDO_REG1 {
				regulator-name = "vdda0v9_image";
				regulator-min-microvolt = <900000>;
				regulator-max-microvolt = <900000>;

				regulator-state-mem {
					regulator-off-in-suspend;
				};
			};

			vdda_0v9: LDO_REG2 {
				regulator-always-on;
				regulator-boot-on;
				regulator-min-microvolt = <900000>;
				regulator-max-microvolt = <900000>;
				regulator-name = "vdda_0v9";

				regulator-state-mem {
					regulator-off-in-suspend;
				};
			};

			vdda0v9_pmu: LDO_REG3 {
				regulator-always-on;
				regulator-boot-on;
				regulator-min-microvolt = <900000>;
				regulator-max-microvolt = <900000>;
				regulator-name = "vdda0v9_pmu";

				regulator-state-mem {
					regulator-on-in-suspend;
					regulator-suspend-microvolt = <900000>;
				};
			};

			vccio_acodec: LDO_REG4 {
				regulator-always-on;
				regulator-min-microvolt = <3300000>;
				regulator-max-microvolt = <3300000>;
				regulator-name = "vccio_acodec";

				regulator-state-mem {
					regulator-off-in-suspend;
				};
			};

			vccio_sd: LDO_REG5 {
				regulator-min-microvolt = <1800000>;
				regulator-max-microvolt = <3300000>;
				regulator-name = "vccio_sd";

				regulator-state-mem {
					regulator-off-in-suspend;
				};
			};

			vcc3v3_pmu: LDO_REG6 {
				regulator-always-on;
				regulator-boot-on;
				regulator-min-microvolt = <3300000>;
				regulator-max-microvolt = <3300000>;
				regulator-name = "vcc3v3_pmu";

				regulator-state-mem {
					regulator-on-in-suspend;
					regulator-suspend-microvolt = <3300000>;
				};
			};

			vcca_1v8: LDO_REG7 {
				regulator-always-on;
				regulator-boot-on;
				regulator-min-microvolt = <1800000>;
				regulator-max-microvolt = <1800000>;
				regulator-name = "vcca_1v8";

				regulator-state-mem {
					regulator-off-in-suspend;
				};
			};

			vcca1v8_pmu: LDO_REG8 {
				regulator-always-on;
				regulator-boot-on;
				regulator-min-microvolt = <1800000>;
				regulator-max-microvolt = <1800000>;
				regulator-name = "vcca1v8_pmu";

				regulator-state-mem {
					regulator-on-in-suspend;
					regulator-suspend-microvolt = <1800000>;
				};
			};

			vcca1v8_image: LDO_REG9 {
				regulator-min-microvolt = <1800000>;
				regulator-max-microvolt = <1800000>;
				regulator-name = "vcca1v8_image";

				regulator-state-mem {
					regulator-off-in-suspend;
				};
			};

			vcc_3v3: SWITCH_REG1 {
				regulator-name = "vcc_3v3";
				regulator-always-on;
				regulator-boot-on;

				regulator-state-mem {
					regulator-off-in-suspend;
				};
			};

			vcc3v3_sd: SWITCH_REG2 {
				regulator-name = "vcc3v3_sd";

				regulator-state-mem {
					regulator-off-in-suspend;
				};
			};
		};

		codec {
			mic-in-differential;
		};
	};
};

&i2c5 {
	status = "okay";
};

&i2s0_8ch {
	status = "okay";
};

&i2s1_8ch {
	rockchip,trcm-sync-tx-only;
	status = "okay";
};

&pcie2x1 {
	reset-gpios = <&gpio2 RK_PD6 GPIO_ACTIVE_HIGH>;
	status = "okay";
};

&pcie30phy {
	data-lanes = <1 2>;
	status = "okay";
};

&pcie30phy {
	status = "okay";
};

&pcie3x1 {
	rockchip,bifurcation;
	reset-gpios = <&gpio3 RK_PA4 GPIO_ACTIVE_HIGH>;
	vpcie3v3-supply = <&vcc3v3_pcie>;
	status = "okay";

	pcie@0,0 {
		reg = <0x00100000 0 0 0 0>;
		#address-cells = <3>;
		#size-cells = <2>;

		rtl8125_1: pcie@10,0 {
			reg = <0x000000 0 0 0 0>;
		};
	};
};

&pcie3x2 {
	rockchip,bifurcation;
	rockchip,init-delay-ms = <100>;
	reset-gpios = <&gpio2 RK_PD0 GPIO_ACTIVE_HIGH>;
	vpcie3v3-supply = <&vcc3v3_pcie>;
	status = "okay";

	pcie@0,0 {
		reg = <0x00200000 0 0 0 0>;
		#address-cells = <3>;
		#size-cells = <2>;

		rtl8125_2: pcie@20,0 {
			reg = <0x000000 0 0 0 0>;
		};
	};
};

&pinctrl {
	button {
		reset_button_pin: reset-button-pin {
			rockchip,pins = <0 RK_PA0 RK_FUNC_GPIO &pcfg_pull_up>;
		};
	};

	leds {
		led_net_en: led_net_en {
			rockchip,pins = <3 RK_PA5 RK_FUNC_GPIO &pcfg_pull_none>;
		};

		led_sata_en: led_sata_en {
			rockchip,pins = <3 RK_PA7 RK_FUNC_GPIO &pcfg_pull_none>;
		};

		led_work_en: led_work_en {
			rockchip,pins = <3 RK_PB0 RK_FUNC_GPIO &pcfg_pull_none>;
		};
	};

	pmic {
		pmic_int: pmic_int {
			rockchip,pins = <0 RK_PA3 RK_FUNC_GPIO &pcfg_pull_up>;
		};
	};

	usb {
		vcc5v0_usb_host_en: vcc5v0_usb_host_en {
			rockchip,pins = <0 RK_PA5 RK_FUNC_GPIO &pcfg_pull_none>;
		};
	};
};

&pmu_io_domains {
	pmuio1-supply = <&vcc3v3_pmu>;
	pmuio2-supply = <&vcc3v3_pmu>;
	vccio1-supply = <&vccio_acodec>;
	vccio2-supply = <&vcc_1v8>;
	vccio3-supply = <&vccio_sd>;
	vccio4-supply = <&vcc_1v8>;
	vccio5-supply = <&vcc_3v3>;
	vccio6-supply = <&vcc_1v8>;
	vccio7-supply = <&vcc_3v3>;
	status = "okay";
};

&pwm0 {
	gpios = <&gpio0 RK_PB7 GPIO_ACTIVE_LOW>;
	pinctrl-0 = <&pwm0m0_pins>;
	status = "okay";
};

&rng {
	status = "okay";
};

&saradc {
	vref-supply = <&vcca_1v8>;
	status = "okay";
};

&sata0 {
	status = "okay";
};

&sdhci {
	bus-width = <8>;
	max-frequency = <200000000>;
	non-removable;
	pinctrl-names = "default";
	pinctrl-0 = <&emmc_bus8 &emmc_clk &emmc_cmd &emmc_datastrobe>;
	status = "okay";
};

&sdmmc0 {
	bus-width = <4>;
	cap-sd-highspeed;
	cd-gpios = <&gpio0 RK_PA4 GPIO_ACTIVE_LOW>;
	disable-wp;
	pinctrl-names = "default";
	pinctrl-0 = <&sdmmc0_bus4 &sdmmc0_clk &sdmmc0_cmd &sdmmc0_det>;
	vmmc-supply = <&vcc3v3_sd>;
	vqmmc-supply = <&vccio_sd>;
	status = "okay";
};

&tsadc {
	rockchip,hw-tshut-mode = <1>;
	rockchip,hw-tshut-polarity = <0>;
	status = "okay";
};

&uart2 {
	status = "okay";
};

&usb_host0_ehci {
	status = "okay";
};

&usb_host0_ohci {
	status = "okay";
};

&usb_host1_ehci {
	status = "okay";
};

&usb_host1_ohci {
	status = "okay";
};

&usb_host1_xhci {
	status = "okay";
};

&usb2phy0 {
	status = "okay";
};

&usb2phy0_host {
	phy-supply = <&vcc5v0_usb_host>;
	status = "okay";
};

&usb2phy1 {
	status = "okay";
};

&usb2phy1_host {
	phy-supply = <&vcc5v0_usb_host>;
	status = "okay";
};

&usb2phy1_otg {
	phy-supply = <&vcc5v0_usb_host>;
	status = "okay";
};

&vop {
	assigned-clocks = <&cru DCLK_VOP0>, <&cru DCLK_VOP1>;
	assigned-clock-parents = <&pmucru PLL_HPLL>, <&cru PLL_VPLL>;
	status = "okay";
};

&vop_mmu {
	status = "okay";
};

&vp0 {
	vp0_out_hdmi: endpoint@ROCKCHIP_VOP2_EP_HDMI0 {
		reg = <ROCKCHIP_VOP2_EP_HDMI0>;
		remote-endpoint = <&hdmi_in_vp0>;
	};
};

EOF

# 5. change patch

sed -i 's/lyt-t68m/opc-h68k/g' target/linux/rockchip/patches-6.6/900-arm64-boot-add-dts-files.patch

# 6. add soc chose

cat << EOF >> target/linux/rockchip/image/armv8.mk

define Device/hinlink_opc-h68k
  DEVICE_VENDOR := HINLINK
  DEVICE_MODEL := OPC-H68K
  SOC := rk3568
  BOOT_FLOW := pine64-img
  DEVICE_PACKAGES := kmod-ata-ahci-platform kmod-hwmon-pwmfan kmod-mt7921e kmod-r8125 wpad-openssl
endef
TARGET_DEVICES += hinlink_opc-h68k
EOF

echo "------------------all files changed -----------------"
