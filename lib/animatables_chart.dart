library animatables_chart;

import 'package:flutter/animation.dart';
import 'package:flutter/widgets.dart';
import 'package:charts_flutter/flutter.dart' as charts;

/////////////////////////////////////
/// Sample use: 
/// class MyApp extends StatelessWidget {
/// 
///   @override
///   Widget build(BuildContext context) {
///     var keyframesAnimation = KeyframesAnimation<double>([KeyFrame(0.0, 0.1), KeyFrame(0.3, 1.0), KeyFrame(1.0, 0.1)]);
///     var shiftedAnimation = ShiftedAnimation(-0.0555555556);
///     return MaterialApp(
///       // theme: ThemeData.dark().copyWith(scaffoldBackgroundColor: darkBlue),
///       debugShowCheckedModeBanner: false,
///       home: Scaffold(
///         body: Center(
///             child: 
///             AnimationsChart(
///           animationSeries: [
///             AnimationSeries(
///               'keyframe',
///               keyframesAnimation,
///             ),
///             AnimationSeries('shift outer-1', shiftedAnimation),
///             AnimationSeries('shift + keyframe', keyframesAnimation.chain(shiftedAnimation))
///           ],
///           seriesSize: 100,
///         )
///             ),
///       ),
///     );
///   }
/// }
///
class AnimationsChart extends StatelessWidget {
  final List<AnimationSeries> animationSeries;
  final int seriesSize;

  const AnimationsChart({Key key, this.animationSeries, this.seriesSize}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return new charts.LineChart(
      _createSeries(),
      animate: false,
      behaviors: [new charts.SeriesLegend()],
      selectionModels: [
        new charts.SelectionModelConfig(
          type: charts.SelectionModelType.info,
          changedListener: _onSelectionChanged,
        )
      ],
    );
  }

  _onSelectionChanged(charts.SelectionModel<num> model) {
    final selectedDatum = model.selectedDatum;
    print('onselectionchanged: $selectedDatum');
    double time;
    final measures = <String, double>{};

    // We get the model that updated with a list of [SeriesDatum] which is
    // simply a pair of series & datum.
    //
    // Walk the selection updating the measures map, storing off the sales and
    // series name for each selection point.
    if (selectedDatum.isNotEmpty) {
      var first = selectedDatum.first;
      time = first.series.data[first.index];
      selectedDatum.forEach((charts.SeriesDatum datumPair) {
        measures[datumPair.series.displayName] = datumPair.series.measureFn(datumPair.index);
      });
    }
    print("time: $time, $measures");
  }

  List<charts.Series> _createSeries() {
    List<double> times = List.generate(seriesSize, (index) => 1.0 / seriesSize * index);
    return animationSeries
        .map((e) => new charts.Series<double, double>(
              id: e.name,
              data: times,
              domainFn: (time, index) => time,
              measureFn: (time, index) => e.animatable.transform(time),
            ))
        .toList();
  }
}

class AnimationSeries {
  final String name;
  final Animatable<double> animatable;

  AnimationSeries(this.name, this.animatable);
}