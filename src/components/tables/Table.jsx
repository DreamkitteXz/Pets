import React from "react";



function Table({ columns, data, rowKey }) {
  return (
    <div className="overflow-x-auto">
      <table className="table-fixed w-full h-full">
        <thead className="bg-white border-b-1 border-t-0">
          <tr>
            {columns.map((column) => (
              <th key={column.key} className="text-gray-500 text-sm">
                {column.header}
              </th>
            ))}
          </tr>
        </thead>
        <tbody>
          {data.map((row) => (
            <tr key={row[rowKey]}>
              {columns.map((column) => (
                <td key={column.key} className="text-slate-600">
                  {column.render ? column.render(row[column.key], row) : row[column.key]}
                </td>
              ))}
            </tr>
          ))}
        </tbody>
      </table>
    </div>
  );
};

export default Table;
