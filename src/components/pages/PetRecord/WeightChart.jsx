import React from 'react';
import {
  LineChart, Line, XAxis, YAxis, Tooltip, ResponsiveContainer, CartesianGrid,
} from 'recharts';
import { toDate } from '../../../utils/dates';

const CustomTooltip = ({ active, payload }) => {
  if (!active || !payload || !payload.length) return null;
  const p = payload[0].payload;
  return (
    <div
      className="px-3 py-2 rounded-[10px]"
      style={{ background: 'var(--surface-elevated)', boxShadow: '0 4px 16px rgba(0,0,0,0.18), 0 0 0 1px var(--separator)' }}
    >
      <div className="font-semibold" style={{ fontSize: '14px', color: 'var(--text-primary)' }}>{p.weight} kg</div>
      <div style={{ fontSize: '12px', color: 'var(--text-secondary)' }}>{p.label}</div>
    </div>
  );
};

export default function WeightChart({ pesos }) {
  const data = (pesos || [])
    .map(p => {
      const d = toDate(p.date);
      return {
        weight: p.weight,
        ts: d ? d.getTime() : 0,
        label: d ? d.toLocaleDateString('pt-BR', { day: '2-digit', month: 'short', year: '2-digit' }) : '—',
        short: d ? d.toLocaleDateString('pt-BR', { day: '2-digit', month: '2-digit' }) : '—',
      };
    })
    .sort((a, b) => a.ts - b.ts);

  if (data.length < 2) {
    return (
      <div className="flex items-center justify-center py-10" style={{ minHeight: '180px' }}>
        <p style={{ fontSize: '14px', color: 'var(--text-tertiary)' }}>
          {data.length === 0 ? 'Nenhum registro de peso ainda.' : 'Registre ao menos 2 pesagens para ver a evolução.'}
        </p>
      </div>
    );
  }

  return (
    <div style={{ width: '100%', height: '220px' }}>
      <ResponsiveContainer width="100%" height="100%">
        <LineChart data={data} margin={{ top: 10, right: 16, bottom: 4, left: -12 }}>
          <CartesianGrid strokeDasharray="3 3" stroke="var(--separator)" vertical={false} />
          <XAxis
            dataKey="short"
            tick={{ fontSize: 11, fill: 'var(--text-tertiary)' }}
            axisLine={false}
            tickLine={false}
          />
          <YAxis
            tick={{ fontSize: 11, fill: 'var(--text-tertiary)' }}
            axisLine={false}
            tickLine={false}
            width={42}
            unit="kg"
          />
          <Tooltip content={<CustomTooltip />} cursor={{ stroke: 'var(--apple-blue)', strokeWidth: 1, strokeDasharray: '4 4' }} />
          <Line
            type="monotone"
            dataKey="weight"
            stroke="var(--apple-blue)"
            strokeWidth={2.5}
            dot={{ r: 3.5, fill: 'var(--apple-blue)', strokeWidth: 0 }}
            activeDot={{ r: 5, fill: 'var(--apple-blue)', stroke: 'var(--surface-grouped-secondary)', strokeWidth: 2 }}
          />
        </LineChart>
      </ResponsiveContainer>
    </div>
  );
}
