import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Required for TextInputFormatter

/// Main entry point for the Flutter application.
void main() {
  runApp(const UnitConverterApp());
}

/// Enum to categorize the type of conversion.
enum UnitCategory { distance, mass }

/// Data model class for a single conversion unit.
class ConversionUnit {
  final String name;
  final String symbol;
  final UnitCategory category;
  final double factorToBase; // Factor to Meter for distance, or Kg for mass

  const ConversionUnit({
    required this.name,
    required this.symbol,
    required this.category,
    required this.factorToBase,
  });
}

/// Global list of all available conversion units.
final List<ConversionUnit> _allUnits = [
  // Distance Units (Base: Meter, factorToBase = meters per unit)
  const ConversionUnit(name: 'Kilometer', symbol: 'km', category: UnitCategory.distance, factorToBase: 1000.0),
  const ConversionUnit(name: 'Mile', symbol: 'mi', category: UnitCategory.distance, factorToBase: 1609.34),
  const ConversionUnit(name: 'Meter', symbol: 'm', category: UnitCategory.distance, factorToBase: 1.0),
  const ConversionUnit(name: 'Foot', symbol: 'ft', category: UnitCategory.distance, factorToBase: 0.3048),
  const ConversionUnit(name: 'Centimeter', symbol: 'cm', category: UnitCategory.distance, factorToBase: 0.01),

  // Mass Units (Base: Kilogram, factorToBase = kilograms per unit)
  const ConversionUnit(name: 'Kilogram', symbol: 'kg', category: UnitCategory.mass, factorToBase: 1.0),
  const ConversionUnit(name: 'Pound', symbol: 'lb', category: UnitCategory.mass, factorToBase: 0.453592),
  const ConversionUnit(name: 'Gram', symbol: 'g', category: UnitCategory.mass, factorToBase: 0.001),
  const ConversionUnit(name: 'Ounce', symbol: 'oz', category: UnitConverterHomeState.mass, factorToBase: 0.0283495),
];

class UnitConverterApp extends StatelessWidget {
  const UnitConverterApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Unit Converter',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple, primary: Colors.deepPurple),
        useMaterial3: true,
        fontFamily: 'Inter',
        // Set a smooth, modern input decoration theme
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.0),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.deepPurple.shade50,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
        ),
      ),
      home: const UnitConverterHome(),
    );
  }
}

class UnitConverterHome extends StatefulWidget {
  const UnitConverterHome({super.key});

  @override
  State<UnitConverterHome> createState() => UnitConverterHomeState();
}

class UnitConverterHomeState extends State<UnitConverterHome> {
  // Constants for Mass and Distance categories for cleaner access in the UI
  static const UnitCategory distance = UnitCategory.distance;
  static const UnitCategory mass = UnitCategory.mass;

  // State variables for the conversion application
  UnitCategory _currentCategory = distance;
  String _inputValue = '';
  String _resultValue = '0.0';
  late ConversionUnit _fromUnit;
  late ConversionUnit _toUnit;

  // Controller for the input field to manage and clear text
  final TextEditingController _inputController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Initialize units to default values (km and kg)
    _initializeUnits();
    // Start listening to text changes
    _inputController.addListener(_performConversion);
  }

  /// Sets the initial 'from' and 'to' units based on the starting category (Distance).
  void _initializeUnits() {
    final distanceUnits = _allUnits.where((u) => u.category == distance).toList();
    setState(() {
      _fromUnit = distanceUnits.first; // Kilometer
      _toUnit = distanceUnits[1]; // Mile
    });
  }

  /// Filters the global unit list based on the currently selected category.
  List<ConversionUnit> _getFilteredUnits() {
    return _allUnits.where((unit) => unit.category == _currentCategory).toList();
  }

  /// Converts a value from one unit to another within the same category.
  /// 1. Converts the 'from' value to the base unit (Meter or Kilogram).
  /// 2. Converts the base unit value to the 'to' unit.
  double _convertValue(double value, ConversionUnit from, ConversionUnit to) {
    // Convert 'from' value to the Base Unit
    final double baseValue = value * from.factorToBase;
    // Convert Base Unit value to the 'to' unit
    final double result = baseValue / to.factorToBase;
    return result;
  }

  /// Main logic function to calculate and update the result.
  void _performConversion() {
    // Check if the widget is mounted before calling setState
    if (!mounted) return;

    final input = _inputController.text;

    if (input.isEmpty) {
      // If input is empty, reset the result
      setState(() {
        _inputValue = '';
        _resultValue = '0.0';
      });
      return;
    }

    try {
      final double value = double.parse(input);
      final double result = _convertValue(value, _fromUnit, _toUnit);
      
      // Format the result to a maximum of 4 decimal places, avoiding trailing zeros
      String formattedResult = result.toStringAsFixed(4);
      if (formattedResult.contains('.')) {
        formattedResult = formattedResult.replaceAll(RegExp(r"([0-9])0+$"), r"$1");
      }
      if (formattedResult.endsWith('.')) {
        formattedResult = formattedResult.substring(0, formattedResult.length - 1);
      }
      
      setState(() {
        _inputValue = input;
        _resultValue = formattedResult;
      });
    } catch (e) {
      // Handle non-numeric input by resetting the result
      setState(() {
        _inputValue = input;
        _resultValue = 'Invalid Input';
      });
    }
  }

  /// Handles the change of the category (Distance or Mass).
  void _onCategoryChange(UnitCategory newCategory) {
    if (_currentCategory == newCategory) return;

    final newUnits = _allUnits.where((u) => u.category == newCategory).toList();
    if (newUnits.length >= 2) {
      setState(() {
        _currentCategory = newCategory;
        _fromUnit = newUnits.first;
        _toUnit = newUnits[1];
        _inputController.clear(); // Clear input on category change
      });
      _performConversion(); // Re-calculate with new default units (will set result to 0.0)
    }
  }

  /// Utility function to swap the 'from' and 'to' units.
  void _swapUnits() {
    setState(() {
      final temp = _fromUnit;
      _fromUnit = _toUnit;
      _toUnit = temp;
    });
    // Immediately perform conversion after swap
    _performConversion();
  }

  @override
  void dispose() {
    _inputController.removeListener(_performConversion);
    _inputController.dispose();
    super.dispose();
  }

  // --- UI Components ---

  /// Builds the segmented control for selecting the conversion category.
  Widget _buildCategorySelector() {
    return SegmentedButton<UnitCategory>(
      style: SegmentedButton.styleFrom(
        foregroundColor: Colors.deepPurple,
        selectedForegroundColor: Colors.white,
        selectedBackgroundColor: Colors.deepPurple,
        side: BorderSide(color: Colors.deepPurple.shade100, width: 1.5),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        textStyle: const TextStyle(fontWeight: FontWeight.w600),
      ),
      segments: const <ButtonSegment<UnitCategory>>[
        ButtonSegment<UnitCategory>(
          value: distance,
          label: Text('Distance'),
          icon: Icon(Icons.compare_arrows_rounded, size: 20),
        ),
        ButtonSegment<UnitCategory>(
          value: mass,
          label: Text('Mass'),
          icon: Icon(Icons.scale_rounded, size: 20),
        ),
      ],
      selected: <UnitCategory>{_currentCategory},
      onSelectionChanged: (Set<UnitCategory> newSelection) {
        _onCategoryChange(newSelection.first);
      },
    );
  }

  /// Builds the text field for the user to input the value.
  Widget _buildInputField() {
    return TextFormField(
      controller: _inputController,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: <TextInputFormatter>[
        // Allows only digits and a single decimal point
        FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
      ],
      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black87),
      decoration: const InputDecoration(
        labelText: 'Input Value',
        hintText: 'Enter value to convert',
        suffixIcon: Icon(Icons.numbers_rounded, color: Colors.deepPurple),
      ),
    );
  }

  /// Builds a dropdown button for unit selection (From or To).
  Widget _buildUnitDropdown(ConversionUnit selectedUnit, Function(ConversionUnit?) onChanged) {
    final filteredUnits = _getFilteredUnits();
    
    // Ensure the selected unit is still valid for the current category
    ConversionUnit? effectiveSelectedUnit = filteredUnits.contains(selectedUnit) ? selectedUnit : filteredUnits.first;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.deepPurple.shade200, width: 1),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<ConversionUnit>(
          value: effectiveSelectedUnit,
          icon: const Icon(Icons.arrow_drop_down_rounded, color: Colors.deepPurple, size: 30),
          isExpanded: true,
          items: filteredUnits.map((ConversionUnit unit) {
            return DropdownMenuItem<ConversionUnit>(
              value: unit,
              child: Text('${unit.name} (${unit.symbol})', style: const TextStyle(fontSize: 16)),
            );
          }).toList(),
          onChanged: (ConversionUnit? newValue) {
            if (newValue != null) {
              onChanged(newValue);
              _performConversion();
            }
          },
        ),
      ),
    );
  }
  
  /// Builds the Result Card displaying the final converted value.
  Widget _buildResultCard() {
    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      color: Colors.deepPurple.shade700,
      child: Padding(
        padding: const EdgeInsets.all(30.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Text(
              'Result',
              style: TextStyle(
                color: Colors.deepPurple.shade200,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                _resultValue,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 48,
                  fontWeight: FontWeight.w900,
                  height: 1.1,
                ),
                textAlign: TextAlign.left,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${_toUnit.name} (${_toUnit.symbol})',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.right,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Unit Converter', style: TextStyle(fontWeight: FontWeight.w700, color: Colors.white)),
        backgroundColor: Colors.deepPurple,
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            // 1. Category Selector
            Center(child: _buildCategorySelector()),
            const SizedBox(height: 32),

            // 2. Input Field
            _buildInputField(),
            const SizedBox(height: 24),

            // 3. Conversion Row (From Unit -> To Unit with Swap Button)
            Row(
              children: <Widget>[
                // From Unit Dropdown
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Padding(
                        padding: EdgeInsets.only(left: 8.0, bottom: 4.0),
                        child: Text('Convert From', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.black54)),
                      ),
                      _buildUnitDropdown(_fromUnit, (newValue) {
                        setState(() => _fromUnit = newValue!);
                      }),
                    ],
                  ),
                ),
                
                // Swap Button
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: IconButton(
                    onPressed: _swapUnits,
                    icon: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.deepPurple.shade100,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.deepPurple.shade100,
                            blurRadius: 4,
                            spreadRadius: 1
                          )
                        ]
                      ),
                      child: const Icon(Icons.cached_rounded, color: Colors.deepPurple, size: 28),
                    ),
                    tooltip: 'Swap Units',
                  ),
                ),
                
                // To Unit Dropdown
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Padding(
                        padding: EdgeInsets.only(left: 8.0, bottom: 4.0),
                        child: Text('Convert To', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.black54)),
                      ),
                      _buildUnitDropdown(_toUnit, (newValue) {
                        setState(() => _toUnit = newValue!);
                      }),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),

            // 4. Result Display Card
            _buildResultCard(),

            const SizedBox(height: 40),
            // Displaying the formula for transparency
            Center(
              child: Text(
                'Converting ${_fromUnit.symbol} to ${_toUnit.symbol}',
                style: TextStyle(
                  color: Colors.deepPurple.shade300,
                  fontSize: 16,
                  fontStyle: FontStyle.italic,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
