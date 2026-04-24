import 'package:flutter/material.dart';

enum CalculatorOptionKind { convert, play }

class CalculatorOption {
  const CalculatorOption({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.kind,
    this.showAdBadge = false,
  });

  final String id;
  final String title;
  final String subtitle;
  final IconData icon;
  final CalculatorOptionKind kind;
  final bool showAdBadge;
}

class ConversionSpec {
  const ConversionSpec({
    required this.id,
    required this.title,
    required this.inputUnit,
    required this.outputUnit,
    required this.compute,
  });

  final String id;
  final String title;
  final String inputUnit;
  final String outputUnit;
  final double Function(double input) compute;
}

const kCalculatorOptions = <CalculatorOption>[
  CalculatorOption(
    id: 'usd_to_rbx',
    title: 'USD to RBX',
    subtitle: 'Convert USD amount\nto RBX value',
    icon: Icons.currency_exchange,
    kind: CalculatorOptionKind.convert,
  ),
  CalculatorOption(
    id: 'rbx_to_usd',
    title: 'RBX to USD',
    subtitle: 'Convert RBX amount\nto USD value',
    icon: Icons.swap_horiz,
    kind: CalculatorOptionKind.convert,
  ),
  CalculatorOption(
    id: 'rbx_to_dollar',
    title: 'RBX to Dollar',
    subtitle: 'Convert RBX amount\nto Dollar value',
    icon: Icons.attach_money,
    kind: CalculatorOptionKind.convert,
  ),
  CalculatorOption(
    id: 'dollar_to_rbx',
    title: 'Dollar to RBX',
    subtitle: 'Convert Dollar amount\nto RBX value',
    icon: Icons.currency_exchange,
    kind: CalculatorOptionKind.convert,
  ),
  CalculatorOption(
    id: 'bc_to_rbx',
    title: 'BC to RBX',
    subtitle: 'Convert BC amount\nto RBX value',
    icon: Icons.change_circle_outlined,
    kind: CalculatorOptionKind.convert,
  ),
  CalculatorOption(
    id: 'tbc_to_rbx',
    title: 'TBC to RBX',
    subtitle: 'Convert TBC amount\nto RBX value',
    icon: Icons.change_circle,
    kind: CalculatorOptionKind.convert,
  ),
  // CalculatorOption(
  //   id: 'obc_to_rbx',
  //   title: 'OBC to RBX',
  //   subtitle: 'Convert OBC amount\nto RBX value',
  //   icon: Icons.cached,
  //   kind: CalculatorOptionKind.convert,
  // ),
  // CalculatorOption(
  //   id: 'play_game',
  //   title: 'Play Game',
  //   subtitle: 'Play smart,\nPlay hard',
  //   icon: Icons.sports_esports,
  //   kind: CalculatorOptionKind.play,
  //   showAdBadge: true,
  // ),
];

// NOTE: Rates are simple defaults. Change here if you want different values.
const kConversionSpecs = <ConversionSpec>[
  ConversionSpec(
    id: 'usd_to_rbx',
    title: 'USD to RBX',
    inputUnit: 'USD',
    outputUnit: 'RBX',
    compute: _usdToRbx,
  ),
  ConversionSpec(
    id: 'rbx_to_usd',
    title: 'RBX to USD',
    inputUnit: 'RBX',
    outputUnit: 'USD',
    compute: _rbxToUsd,
  ),
  ConversionSpec(
    id: 'rbx_to_dollar',
    title: 'RBX to Dollar',
    inputUnit: 'RBX',
    outputUnit: 'Dollar',
    compute: _rbxToUsd,
  ),
  ConversionSpec(
    id: 'dollar_to_rbx',
    title: 'Dollar to RBX',
    inputUnit: 'Dollar',
    outputUnit: 'RBX',
    compute: _usdToRbx,
  ),
  ConversionSpec(
    id: 'bc_to_rbx',
    title: 'BC to RBX',
    inputUnit: 'BC',
    outputUnit: 'RBX',
    compute: _bcToRbx,
  ),
  ConversionSpec(
    id: 'tbc_to_rbx',
    title: 'TBC to RBX',
    inputUnit: 'TBC',
    outputUnit: 'RBX',
    compute: _tbcToRbx,
  ),
  ConversionSpec(
    id: 'obc_to_rbx',
    title: 'OBC to RBX',
    inputUnit: 'OBC',
    outputUnit: 'RBX',
    compute: _obcToRbx,
  ),
];

// Default conversion assumptions:
// - 1 USD = 80 RBX (so 1 RBX = 0.0125 USD)
double _usdToRbx(double usd) => usd * 80.0;
double _rbxToUsd(double rbx) => rbx / 80.0;

// Builders Club legacy values: simple placeholders.
double _bcToRbx(double bc) => bc * 15.0;
double _tbcToRbx(double tbc) => tbc * 35.0;
double _obcToRbx(double obc) => obc * 60.0;
