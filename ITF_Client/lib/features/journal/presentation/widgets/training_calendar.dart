import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/training_session.dart';

class TrainingCalendar extends StatefulWidget {
  const TrainingCalendar({
    super.key,
    required this.sessions,
    this.showNavigation = false,
    this.onMonthChanged,
    this.onDayTap,
  });

  final List<TrainingSession> sessions;
  final bool showNavigation;
  final ValueChanged<DateTime>? onMonthChanged;
  final ValueChanged<DateTime>? onDayTap;

  @override
  State<TrainingCalendar> createState() => _TrainingCalendarState();
}

class _TrainingCalendarState extends State<TrainingCalendar> {
  late DateTime _displayMonth;
  final DateTime _today = DateUtils.dateOnly(DateTime.now());

  @override
  void initState() {
    super.initState();
    _displayMonth = DateTime(_today.year, _today.month);
  }

  Set<DateTime> get _trainingDays => widget.sessions
      .map((s) => DateUtils.dateOnly(s.date))
      .toSet();

  bool get _isCurrentMonth =>
      _displayMonth.year == _today.year && _displayMonth.month == _today.month;

  void _prevMonth() {
    setState(() {
      _displayMonth = DateTime(_displayMonth.year, _displayMonth.month - 1);
    });
    widget.onMonthChanged?.call(_displayMonth);
  }

  void _nextMonth() {
    if (_isCurrentMonth) return;
    setState(() {
      _displayMonth = DateTime(_displayMonth.year, _displayMonth.month + 1);
    });
    widget.onMonthChanged?.call(_displayMonth);
  }

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context).languageCode;
    final monthLabel = DateFormat.yMMMM(locale).format(_displayMonth);

    final firstDay = DateTime(_displayMonth.year, _displayMonth.month, 1);
    final daysInMonth =
        DateTime(_displayMonth.year, _displayMonth.month + 1, 0).day;
    // ISO weekday: Mon=1 ... Sun=7, we want offset Mon=0
    final startOffset = (firstDay.weekday - 1) % 7;

    final weekdays = _weekdayLabels(locale);
    final trainingDays = _trainingDays;

    return Column(
      children: [
        // Month header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            if (widget.showNavigation)
              IconButton(
                icon: const Icon(Icons.chevron_left, size: 20),
                onPressed: _prevMonth,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
              )
            else
              const SizedBox(width: 36),
            Text(monthLabel,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    )),
            if (widget.showNavigation)
              IconButton(
                icon: Icon(Icons.chevron_right,
                    size: 20,
                    color: _isCurrentMonth
                        ? AppColors.textDisabled
                        : null),
                onPressed: _isCurrentMonth ? null : _nextMonth,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
              )
            else
              const SizedBox(width: 36),
          ],
        ),
        const SizedBox(height: 4),
        // Weekday headers
        Row(
          children: weekdays
              .map(
                (d) => Expanded(
                  child: Center(
                    child: Text(
                      d,
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              )
              .toList(),
        ),
        const SizedBox(height: 6),
        // Days grid
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 7,
            childAspectRatio: 1.1,
          ),
          itemCount: startOffset + daysInMonth,
          itemBuilder: (context, index) {
            if (index < startOffset) return const SizedBox();
            final day = index - startOffset + 1;
            final date =
                DateTime(_displayMonth.year, _displayMonth.month, day);
            final isToday = DateUtils.isSameDay(date, _today);
            final hasTraining = trainingDays.contains(date);
            final isFuture = date.isAfter(_today);

            return _DayCell(
              day: day,
              isToday: isToday,
              hasTraining: hasTraining,
              isFuture: isFuture,
              onTap: hasTraining && widget.onDayTap != null
                  ? () => widget.onDayTap!(date)
                  : null,
            );
          },
        ),
      ],
    );
  }

  List<String> _weekdayLabels(String locale) {
    // 2024-01-01 is a Monday — use as anchor
    final anchor = DateTime(2024, 1, 1);
    final fmt = DateFormat('EEE', locale == 'ko' ? 'ko' : locale);
    return List.generate(7, (i) => fmt.format(anchor.add(Duration(days: i))));
  }
}

// ── Day cell ─────────────────────────────────────────────────────────────────

class _DayCell extends StatelessWidget {
  const _DayCell({
    required this.day,
    required this.isToday,
    required this.hasTraining,
    required this.isFuture,
    this.onTap,
  });

  final int day;
  final bool isToday;
  final bool hasTraining;
  final bool isFuture;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final cell = Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        color: hasTraining ? AppColors.itfRed : Colors.transparent,
        shape: BoxShape.circle,
        border: isToday
            ? Border.all(
                color: hasTraining ? AppColors.itfRedDark : AppColors.itfRed,
                width: 1.5,
              )
            : null,
      ),
      child: Center(
        child: Text(
          '$day',
          style: TextStyle(
            fontSize: 12,
            fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
            color: hasTraining
                ? Colors.white
                : isFuture
                    ? AppColors.textDisabled
                    : isToday
                        ? AppColors.itfRed
                        : null,
          ),
        ),
      ),
    );

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        onTap != null
            ? GestureDetector(
                onTap: onTap,
                child: cell,
              )
            : cell,
      ],
    );
  }
}
