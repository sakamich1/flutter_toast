library easy_toast;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:easy_toast/src/const.dart';

class Toast extends StatefulWidget {
  final String msg;
  final int duration;

  Toast(this.msg,{this.duration});

  @override
  State<StatefulWidget> createState() => _ToastState();
}

class _ToastState extends State<Toast> with SingleTickerProviderStateMixin {
  AnimationController _controller;
  Animation _animation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this, //类需要实现TickerProviderStateMixin
      duration: Duration(milliseconds: 200),
    );

    _animation = Tween(
      begin: 0.0,
      end: 1.0,
    ).animate(_controller);

    _animation.addStatusListener((status) {
      //print('status -> $status');  //forward -> completed -> reverse -> dismissed
      if (status == AnimationStatus.dismissed) {
        Global.toast.remove(); //移除当前overlay，否则当前context以外部分无法点击
        Global.toast = null;
      }
    });

    Future.delayed(Duration(milliseconds: widget.duration)).then((value) {
      _controller.reverse();
    });
  }

  @override
  Widget build(BuildContext context) {
    _controller.forward(); //初始化完立刻执行动画 0->1

    return FadeTransition(
      child: Container(
        color: Colors.transparent,
        margin: EdgeInsets.only(
          top: MediaQuery
            .of(context)
            .size
            .height * 0.65,
        ),
        alignment: Alignment.center,
        child: Center(
          child: Container(
            padding: const EdgeInsets.fromLTRB(15,8,15,8),
            margin: const EdgeInsets.fromLTRB(50,0,50,0), //最大宽度 两边留50
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(6),
              color: const Color(0xCC000000)
            ),
            child: Text(
              widget.msg,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w300,
                color: Colors.white,
                backgroundColor: Colors.transparent,
                decoration: TextDecoration.none,
              ),
              maxLines: 5,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        )
      ),
      opacity: _animation,);
  }
}

void toast(String msg,{int duration = 2000,context: BuildContext}) {
  OverlayEntry entry = OverlayEntry(
    builder: (context) => Toast(msg,duration: duration,));
  if (Global.toast == null) { //防止重复弹出
    Overlay.of(Global.currContext).insert(entry);
    Global.toast = entry; //当前overlay对象赋值给全局
  }
}
