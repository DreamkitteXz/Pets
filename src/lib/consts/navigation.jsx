import { LayoutDashboard, PawPrint, Syringe, Building2, MessageSquare, Home } from 'lucide-react';
import { HiOutlineQuestionMarkCircle, HiOutlineCog } from 'react-icons/hi';

// Veterinarian navigation
export const DASHBOARD_SIDEBAR_LINKS = [
	{
		key: 'dashboard',
		label: 'Dashboard',
		path: '/dashboard',
		icon: <LayoutDashboard size={20} strokeWidth={1.5} />,
	},
	{
		key: 'pacientes',
		label: 'Meus Pacientes',
		path: '/pets',
		icon: <PawPrint size={20} strokeWidth={1.5} />,
	},
	{
		key: 'vacinas',
		label: 'Vacinas',
		path: '/vacinas',
		icon: <Syringe size={20} strokeWidth={1.5} />,
	},
	{
		key: 'clinicas',
		label: 'Clínicas',
		path: '/clinicas',
		icon: <Building2 size={20} strokeWidth={1.5} />,
	},
	{
		key: 'chat',
		label: 'Chat',
		path: '/chat',
		icon: <MessageSquare size={20} strokeWidth={1.5} />,
	},
]

// Tutor navigation
export const TUTOR_SIDEBAR_LINKS = [
	{
		key: 'inicio',
		label: 'Início',
		path: '/inicio',
		icon: <Home size={20} strokeWidth={1.5} />,
	},
	{
		key: 'meus-pets',
		label: 'Meus Pets',
		path: '/meus-pets',
		icon: <PawPrint size={20} strokeWidth={1.5} />,
	},
	{
		key: 'minhas-vacinas',
		label: 'Vacinas',
		path: '/minhas-vacinas',
		icon: <Syringe size={20} strokeWidth={1.5} />,
	},
]

export const DASHBOARD_SIDEBAR_BOTTOM_LINKS = [
	{
		key: 'settings',
		label: 'Configurações',
		path: '/settings',
		icon: <HiOutlineCog />,
	},
	{
		key: 'support',
		label: 'Ajuda & Suporte',
		path: '/support',
		icon: <HiOutlineQuestionMarkCircle />,
	},
]
