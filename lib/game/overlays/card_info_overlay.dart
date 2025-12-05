part of '../../main.dart';

class CardInfoOverlay extends StatefulWidget {
  final YGOCard card;
  final DuelGame game;

  const CardInfoOverlay({
    super.key,
    required this.card,
    required this.game
  });

  @override
  State<CardInfoOverlay> createState() => _CardInfoOverlayState();
}

class _CardInfoOverlayState extends State<CardInfoOverlay> {
  @override
  Widget build(BuildContext context) {
    final appState = context.watch<MyAppState>();
    final screenSize = MediaQuery.of(context).size;
    final cardGradient = CardColor.getCardGradient(widget.card.frameType);
    final isLandscape = screenSize.width > screenSize.height * 1.5;
    final fontTitles = isLandscape ? screenSize.height * 0.08 : screenSize.width * 0.8 * 0.1;
    final fontDesc = isLandscape ?
      screenSize.height > 400 ?
        30.0 : screenSize.height * 0.7 * 0.1
          :
        screenSize.width > 400 ?
          30.0 : screenSize.width * 0.7 * 0.1;
    final attribSize = isLandscape ?
      screenSize.height * 0.08 :
      screenSize.width * 0.8 * 0.1;

    Uint8List? imageByte = appState.images[widget.card.id];

    return Scaffold(
      body: Container(
        width: screenSize.width,
        height: screenSize.height,
        decoration: BoxDecoration(
            gradient: cardGradient
        ),
        child: Row(
          children: [
            !isLandscape ? Container() :
            SizedBox(
              height: screenSize.height,
              width: screenSize.height,
              child: Column(
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(8,8,0,8.0),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.transparent,
                          borderRadius: BorderRadius.circular(2),
                          border: Border.all(
                            color: Colors.black.withAlpha(50),
                            width: 4,
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                  child: Text(
                                    widget.card.name,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: fontTitles,
                                      fontWeight: FontWeight.bold,
                                      fontFamily: 'Matrix',
                                      height: 1,
                                      shadows: [
                                        Shadow(
                                          color: Colors.black.withAlpha(95),
                                          offset: const Offset(2.0, 2.0),
                                          blurRadius: 3.0,
                                        ),
                                        Shadow(
                                          color: Colors.white.withAlpha(5),
                                          offset: const Offset(1.0, 1.0),
                                          blurRadius: 1.0,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(
                                width: attribSize,
                                height: attribSize,
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.transparent,
                                    borderRadius: BorderRadius.circular(100),
                                    border: Border.all(
                                      color: Colors.white,
                                      width: 1,
                                    ),
                                  ),
                                  child: widget.card.attribute == null ?
                                  appState.attributeImages[widget.card.frameType] :
                                  appState.attributeImages[widget.card.attribute],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),Row(
                    mainAxisAlignment: widget.card.frameType!.contains('xyz') ?
                    MainAxisAlignment.start :
                    MainAxisAlignment.end,
                    children: List.generate(widget.card.level!,
                          (index) => SizedBox(
                        width: 32,
                        height: 32,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.transparent,
                            borderRadius: BorderRadius.circular(100),
                            border: Border.all(
                              color: Colors.white,
                              width: 1,
                            ),
                          ),
                          child: widget.card.frameType!.contains('xyz') ?
                          appState.attributeImages['rank']! :
                          appState.attributeImages['level']!,
                        ),
                      ),
                    ),
                  ),
                  !isLandscape ? Container() :
                  Center(
                    child: imageByte == null ? Container() :
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: SizedBox(
                        width: screenSize.height * 0.67,
                        height: screenSize.height * 0.67,
                        child: Image.memory(
                          imageByte,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    isLandscape ? Container() : Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.transparent,
                          borderRadius: BorderRadius.circular(2),
                          border: Border.all(
                            color: Colors.black.withAlpha(50),
                            width: 4,
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                    widget.card.name,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: fontTitles,
                                      fontWeight: FontWeight.bold,
                                      fontFamily: 'Matrix',
                                      height: 1,
                                      shadows: [
                                        Shadow(
                                          color: Colors.black.withAlpha(95),
                                          offset: const Offset(2.0, 2.0),
                                          blurRadius: 3.0,
                                        ),
                                        Shadow(
                                          color: Colors.white.withAlpha(5),
                                          offset: const Offset(1.0, 1.0),
                                          blurRadius: 1.0,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(
                                width: attribSize,
                                height: attribSize,
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.transparent,
                                    borderRadius: BorderRadius.circular(100),
                                    border: Border.all(
                                      color: Colors.white,
                                      width: 1,
                                    ),
                                  ),
                                  child: widget.card.attribute == null ?
                                  appState.attributeImages[widget.card.frameType] :
                                  appState.attributeImages[widget.card.attribute],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    isLandscape ? Container() :
                    Row(
                      mainAxisAlignment: widget.card.frameType!.contains('xyz') ?
                      MainAxisAlignment.start :
                      MainAxisAlignment.end,
                      children: List.generate(widget.card.level!,
                            (index) => SizedBox(
                          width: 32,
                          height: 32,
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.transparent,
                              borderRadius: BorderRadius.circular(100),
                              border: Border.all(
                                color: Colors.white,
                                width: 1,
                              ),
                            ),
                            child: widget.card.frameType!.contains('xyz') ?
                            appState.attributeImages['rank']! :
                            appState.attributeImages['level']!,
                          ),
                        ),
                      ),
                    ),
                    isLandscape ? Container() :
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 5.0),
                      child: Center(
                        child: imageByte == null ? Container() :
                        SizedBox(
                          width: screenSize.width,
                          height: screenSize.width,
                          child: Image.memory(
                            imageByte,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                    widget.card.pendDesc == null ? Container() :
                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withAlpha(200),
                          borderRadius: BorderRadius.circular(3),
                          border: Border.all(
                            color: Color(0xFF109B80),
                            width: 5,
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Text(
                            widget.card.pendDesc!,
                            textAlign: TextAlign.justify,
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: fontDesc,
                              fontWeight: FontWeight.normal,
                              fontFamily: 'Matrix',
                              height: 1,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withAlpha(200),
                          borderRadius: BorderRadius.circular(3),
                          border: Border.all(
                            color: Colors.amber,
                            width: 5,
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Column(
                            children: [
                              typeLineWriter(
                                  widget.card.typeLine,
                                  isLandscape ?
                                  screenSize.height * 0.7 * 0.1 :
                                  screenSize.width * 0.7 * 0.1
                              ),
                              Text(
                                widget.card.pendDesc == null ?
                                widget.card.desc :
                                widget.card.monsterDesc!,
                                textAlign: TextAlign.justify,
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: fontDesc,
                                  fontWeight: FontWeight.normal,
                                  fontFamily: 'Matrix',
                                  height: 1,
                                ),
                              ),
                              widget.card.atk == null ? Container() :
                              const Divider(
                                color: Colors.black,
                                thickness: 1,
                              ),
                              widget.card.atk == null ? Container() :
                              Row(
                                children: [
                                  Expanded(
                                    child: atkDefLinkWriter(
                                        widget.card.atk,
                                        widget.card.def,
                                        widget.card.linkVal,
                                        isLandscape ?
                                        screenSize.height * 0.7 * 0.1 :
                                        screenSize.width * 0.7 * 0.1
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Row(
                        children: [
                          Expanded(
                            child: widget.card.archetype == null ? Container() : Text(
                              'Archetype: ${widget.card.archetype!}',
                              textAlign: TextAlign.left,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: fontDesc,
                                fontWeight: FontWeight.normal,
                                fontFamily: 'Matrix',
                                height: 1,
                                shadows: [
                                  Shadow(
                                    color: Colors.black.withAlpha(95),
                                    offset: const Offset(2.0, 2.0),
                                    blurRadius: 3.0,
                                  ),
                                  Shadow(
                                    color: Colors.white.withAlpha(5),
                                    offset: const Offset(1.0, 1.0),
                                    blurRadius: 1.0,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(15.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Container(
                                    width: 40,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      color: Colors.red,
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: BackButton(
                                      onPressed: () => widget.game.hideCardInfo(),
                                    ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget typeLineWriter(List<String>? types, double fontSize) {
    if (types == null) {
      return Container();
    }

    var text = '[${types[0]}';
    for (var i = 1; i < types.length; i++) {
      text += '/';
      text += types[i];
    }
    text += ']';

    return Text(
      text.toUpperCase(),
      textAlign: TextAlign.right,
      style: TextStyle(
        color: Colors.black,
        fontSize: fontSize * 1.1,
        fontWeight: FontWeight.bold,
        fontFamily: 'Matrix',
        height: 1,
        shadows: [
          Shadow(
            color: Colors.black.withAlpha(95),
            offset: const Offset(2.0, 2.0),
            blurRadius: 3.0,
          ),
          Shadow(
            color: Colors.white.withAlpha(5),
            offset: const Offset(1.0, 1.0),
            blurRadius: 1.0,
          ),
        ],
      ),
    );
  }

  Widget atkDefLinkWriter(int? atk, int? def, int? linkval, double fontSize) {
    if (atk == null && def == null) {
      return Container();
    }

    var text = atk! > -1 ? 'ATK/$atk' : 'ATK/   ?';

    if (def == null) {
      text += ' LINK-$linkval';
    }
    else {
      text += def > -1 ? ' DEF/$def' : ' DEF/   ?';
    }

    return Text(
      text,
      textAlign: TextAlign.right,
      maxLines: 1,
      style: TextStyle(
        color: Colors.black,
        fontSize: fontSize * 1.1,
        fontWeight: FontWeight.bold,
        fontFamily: 'Matrix',
        height: 1,
        shadows: [
          Shadow(
            color: Colors.black.withAlpha(95),
            offset: const Offset(2.0, 2.0),
            blurRadius: 3.0,
          ),
          Shadow(
            color: Colors.white.withAlpha(5),
            offset: const Offset(1.0, 1.0),
            blurRadius: 1.0,
          ),
        ],
      ),
    );
  }
}