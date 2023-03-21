import 'dart:async';
import 'dart:developer';

import 'package:calendar/components/cards/primary_card.dart';
import 'package:calendar/components/custom_text_form_field.dart';
import 'package:calendar/components/expandable_widget.dart';
import 'package:calendar/realm/schemas.dart';
import 'package:calendar/screens/create_edit_event/create_edit_event.dart';
import 'package:calendar/util/consts.dart';
import 'package:flutter/material.dart';
import "package:google_maps_webservice/places.dart";

class LocationPicker extends StatefulWidget {
  final bool isOpen;
  final Function(OpenPicker) setExpanded;
  final LocationData? selectedLocation;
  final void Function(LocationData) setLocation;

  const LocationPicker(
      {Key? key,
      required this.isOpen,
      required this.setExpanded,
      required this.selectedLocation,
      required this.setLocation})
      : super(key: key);

  @override
  State<LocationPicker> createState() => LocationPickerState();
}

class LocationPickerState extends State<LocationPicker> {
  final placesApi = GoogleMapsPlaces(apiKey: googleApiKey);
  final FocusNode focusNode = FocusNode();

  int lastSearchTime = 0;
  int debounceTime = 500;
  Timer? pendingSearchTimer;
  List<PlacesSearchResult> places = [];
  String? error;

  @override
  void dispose() {
    pendingSearchTimer?.cancel();
    super.dispose();
  }

  toggleDatePicker() {
    widget.setExpanded(widget.isOpen ? OpenPicker.none : OpenPicker.location);

    Timer(const Duration(milliseconds: 400), () {
      if (widget.isOpen) focusNode.requestFocus();
    });
  }

  void handleSetLocation(PlacesSearchResult place) {
    final locationData = LocationData(place.name, place.formattedAddress ?? '',
        place.geometry?.location.lat ?? 0, place.geometry?.location.lng ?? 0,
        googlePlaceId: place.placeId);
    widget.setLocation(locationData);
  }

  onLocationTextChange(String str) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    if (now < lastSearchTime + debounceTime) {
      // search final input if there were no subsequent searches
      pendingSearchTimer?.cancel();
      pendingSearchTimer = Timer(
          Duration(milliseconds: lastSearchTime + debounceTime - now),
          () => onLocationTextChange(str));
      return;
    }

    lastSearchTime = now;
    pendingSearchTimer?.cancel();
    pendingSearchTimer = null;

    final response = await placesApi.searchByText(str);
    if (response.errorMessage != null) {
      setState(() => error = response.errorMessage);
      return;
    }

    setState(() => places = response.results);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return PrimaryCard(
        padding: EdgeInsets.zero,
        child: Column(children: [
          GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: toggleDatePicker,
              child: Container(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Location',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        Text(widget.selectedLocation == null
                            ? 'None'
                            : widget.selectedLocation!.name)
                      ]))),
          ExpandedableWidget(
              curve: Curves.easeInOut,
              expand: widget.isOpen,
              axisAlignment: -1,
              child: Column(children: [
                Container(height: 1, color: Colors.grey[200]),
                CustomTextFormField(
                  focusNode: focusNode,
                  hintText: 'Search Locations',
                  onChanged: onLocationTextChange,
                  fillColor: theme.backgroundColor,
                  margin: const EdgeInsets.all(8),
                  padding: const EdgeInsets.all(8),
                  borderRadius: 0,
                ),
                if (error != null)
                  Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: Text(
                        'Error: ${error!}',
                        style: const TextStyle(color: Colors.red),
                      )),
                if (places.isNotEmpty)
                  SizedBox(
                      height: 200,
                      child: ListView.separated(
                          itemCount: places.length,
                          separatorBuilder: (BuildContext context, int index) =>
                              const Divider(height: 1),
                          itemBuilder: (_, i) {
                            final place = places[i];
                            return Material(
                                child: InkWell(
                                    onTap: () => handleSetLocation(place),
                                    child: Padding(
                                        padding: const EdgeInsets.all(8),
                                        child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                place.name,
                                                style: const TextStyle(
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                              if (place.formattedAddress !=
                                                  null)
                                                Text(place.formattedAddress!,
                                                    style: const TextStyle(
                                                        fontSize: 10)),
                                            ]))));
                          }))
              ]))
        ]));
  }
}
