import React from 'react';
import { Topbar } from '@/components/layout/Topbar';
import { UserTable } from '@/components/users/UserTable';

export default function UsersPage() {
  return (
    <>
      <Topbar
        title="Student User Management"
        description="Search, filter, inspect, and export all registered KPK E-Textbooks students"
      />

      <UserTable />
    </>
  );
}
