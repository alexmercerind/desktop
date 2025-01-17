import 'package:desktop/desktop.dart';
import 'defaults.dart';

class TypographyPage extends StatefulWidget {
  TypographyPage({Key? key}) : super(key: key);

  @override
  _TypographyPageState createState() => _TypographyPageState();
}

class _TypographyPageState extends State<TypographyPage> {
  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return SingleChildScrollView(
      controller: ScrollController(),
      child: Container(
        alignment: Alignment.topLeft,
        margin: EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          children: [
            Defaults.createHeader(context, 'Typography'),
            Column(
              children: [
                Container(
                  alignment: Alignment.centerLeft,
                  padding: EdgeInsets.symmetric(vertical: 16.0),
                  child: Text(
                    'Header/IBM Plex Sans/Light/44',
                    style: textTheme.header,
                  ),
                ),
                Container(
                  alignment: Alignment.centerLeft,
                  padding: EdgeInsets.symmetric(vertical: 16.0),
                  child: Text(
                    'Subheader/IBM Plex Sans/Light/34',
                    style: textTheme.subheader,
                  ),
                ),
                Container(
                  alignment: Alignment.centerLeft,
                  padding: EdgeInsets.symmetric(vertical: 16.0),
                  child: Text(
                    'Title/IBM Plex Sans/Regular/24',
                    style: textTheme.title,
                  ),
                ),
                Container(
                  alignment: Alignment.centerLeft,
                  padding: EdgeInsets.symmetric(vertical: 16.0),
                  child: Text(
                    'Subtitle/IBM Plex Sans/Regular/20',
                    style: textTheme.subtitle,
                  ),
                ),
                Container(
                  alignment: Alignment.centerLeft,
                  padding: EdgeInsets.symmetric(vertical: 16.0),
                  child: Text(
                    'Body1/IBM Plex Sans/Regular/14',
                    style: textTheme.body1,
                  ),
                ),
                Container(
                  alignment: Alignment.centerLeft,
                  padding: EdgeInsets.symmetric(vertical: 16.0),
                  child: Text(
                    'Body2/IBM Plex Sans/Medium/14',
                    style: textTheme.body2,
                  ),
                ),
                Container(
                  alignment: Alignment.centerLeft,
                  padding: EdgeInsets.symmetric(vertical: 16.0),
                  child: Text(
                    'Monospace/IBM Plex Mono/Regular/13',
                    style: textTheme.monospace,
                  ),
                ),
                Container(
                  alignment: Alignment.centerLeft,
                  padding: EdgeInsets.symmetric(vertical: 16.0),
                  child: Text(
                    'Caption/IBM Plex Sans/Regular/12',
                    style: textTheme.caption,
                  ),
                ),
              ],
            ),
            Defaults.createTitle(context, 'Text'),
            Container(
              decoration: Defaults.itemDecoration(context),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    padding: EdgeInsets.all(16.0),
                    child: Text(
                      'Text High',
                      style: textTheme.subtitle.copyWith(
                        color: textTheme.textHigh,
                      ),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.all(16.0),
                    child: Text(
                      'Text Medium',
                      style: textTheme.subtitle.copyWith(
                        color: textTheme.textMedium,
                      ),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.all(16.0),
                    child: Text(
                      'Text Low',
                      style: textTheme.subtitle.copyWith(
                        color: textTheme.textLow,
                      ),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.all(16.0),
                    child: Text(
                      'Text Disabled',
                      style: textTheme.subtitle.copyWith(
                        color: textTheme.textDisabled,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
