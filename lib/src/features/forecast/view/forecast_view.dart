import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';
import 'package:weathered/src/features/forecast/data/providers.dart';
import 'package:weathered/src/features/home/data/weather_icon_handler.dart';

import '../../../core/components/common.dart';
import '../../../utils/style.dart';

class ForecastView extends ConsumerStatefulWidget {
  const ForecastView({super.key});

  @override
  ConsumerState<ForecastView> createState() => _ForecastViewState();
}

class _ForecastViewState extends ConsumerState<ForecastView> {
  void _showWeatherDetails(BuildContext context, dynamic weatherData) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            "Weather Details",
            style: AppStyle.textTheme.titleSmall,
            textAlign: TextAlign.center,
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text("${weatherData['date']}",
                  style: AppStyle.textTheme.titleSmall),
              Container(
                height: 128,
                width: 128,
                child: WeatherIconHandler.getImage(
                      iconCode: weatherData['iconCode'],
                    ) ?? Image.network(
                    "https://openweathermap.org/img/wn/${weatherData['iconCode']}@4x.png"),
              ),
              Text("Maximum: ${weatherData['tempMax']}°C"),
              Text("Minimum: ${weatherData['tempMin']}°C"),
              Text("Description: ${weatherData['description']}"),
              // Add more weather details here
            ],
          ),
          actions: [
            TextButton(
              child: const Text("Close"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final quarterlyForecast = ref.watch(quarterlyWeatherDataProvider);
    return Scaffold(
      body: quarterlyForecast.when(data: (data) {
        return Column(
          children: [
            const Gap(8),
            Center(
              child: Text(
                'Daily Forecast',
                style: AppStyle.textTheme.titleLarge,
              ),
            ),
            const Gap(8),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: ListView.builder(
                  itemCount: 5,
                  itemBuilder: (context, index) {
                    final filterIndex = index * 8;
                    DateTime date =
                        DateTime.parse(data.list[filterIndex].dtTxt);
                    String formattedDate =
                        DateFormat.MMMMd('en_US').format(date);

                    return GestureDetector(
                      onTap: () {
                        _showWeatherDetails(context, {
                          'iconCode': data.list[filterIndex].weather[0].icon,
                          'date': formattedDate,
                          'tempMax': data.list[filterIndex].main.tempMax
                              .toStringAsFixed(0),
                          'tempMin': (data.list[filterIndex].main.tempMin - 5)
                              .toStringAsFixed(0),
                          'description':
                              data.list[filterIndex].weather[0].description,
                        });
                      },
                      child: MatContainer.primary(
                          context: context,
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(12, 12, 16, 12),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Padding(
                                  padding:
                                      const EdgeInsets.fromLTRB(15, 0, 0, 0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        formattedDate,
                                        // data.list[filterIndex].dtTxt.substring(0, 10),
                                        style: AppStyle.textTheme.titleSmall,
                                      ),
                                      Text(data.list[filterIndex].weather[0]
                                          .description),
                                    ],
                                  ),
                                ),
                                Row(
                                  children: [
                                    Container(
                                      height: 128,
                                      width: 128,
                                      child: WeatherIconHandler.getImage(
                                            iconCode: data.list[filterIndex]
                                                .weather[0].icon,
                                          ) ??
                                          Image.network(
                                              "https://openweathermap.org/img/wn/${data.list[filterIndex].weather[0].icon}@2x.png"),
                                    ),
                                    const Gap(10),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      children: [
                                        Text(
                                            "${(data.list[filterIndex].main.tempMin - 5).toStringAsFixed(0)}°C"),
                                        Text(
                                            "${data.list[filterIndex].main.tempMax.toStringAsFixed(0)}°C"),
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          )),
                    );
                  },
                ),
              ),
            ),
          ],
        );
      }, error: (error, stackTrace) {
        return Center(
          child: Text(
            'Error : $error',
            textAlign: TextAlign.center,
          ),
        );
      }, loading: () {
        return const Center(
          child: CircularProgressIndicator(),
        );
      }),
    );
  }
}
