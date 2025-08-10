import { getSchedule } from "@/data/schedule";

export default function SchedulePage() {
  const schedule = getSchedule();
  return (
    <div className="space-y-4">
      <h1 className="text-center text-xl font-semibold">Schedule</h1>
      <div className="space-y-2">
        {schedule.slice(0, 10).map((day) => (
          <div key={day.day} className="container-card p-4">
            <div className="font-semibold">Day {day.day}</div>
            <div className="text-sm text-zinc-400">{day.title}</div>
          </div>
        ))}
        <div className="text-sm text-zinc-500">Showing first 10 days for now.</div>
      </div>
    </div>
  );
}
