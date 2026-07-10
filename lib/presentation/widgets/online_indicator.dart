import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/connectivity_cubit.dart';

class OnlineIndicator extends StatelessWidget {
  const OnlineIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ConnectivityCubit, bool>(
      builder: (context, online) {
        final color = online ? Colors.green : Colors.red;
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Row(
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              ),
              const SizedBox(width: 6),
              Text(
                online ? 'Online' : 'Offline',
                style: TextStyle(color: color, fontSize: 12),
              ),
            ],
          ),
        );
      },
    );
  }
}
