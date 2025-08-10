export type ScheduleDay = { day: number; title: string };

export function getSchedule(): ScheduleDay[] {
  const days: ScheduleDay[] = [];
  const chapters = [
    "Philippians 1:1-11",
    "Philippians 1:12-30",
    "Philippians 2:1-11",
    "Philippians 2:12-30",
    "Philippians 3:1-11",
    "Philippians 3:12-21",
    "Philippians 4:1-9",
    "Philippians 4:10-23",
  ];
  for (let i = 1; i <= 90; i++) {
    const pick = chapters[(i - 1) % chapters.length];
    days.push({ day: i, title: pick });
  }
  return days;
}
