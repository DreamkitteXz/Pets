import {
	HiOutlineQuestionMarkCircle,
	HiOutlineCog
} from 'react-icons/hi'
import {TbVaccine}  from 'react-icons/tb'
import {MdOutlinePets,MdDashboard} from 'react-icons/md'

export const DASHBOARD_SIDEBAR_LINKS = [
	{
		key: 'dashboard',
		label: 'Dashboard',
		path: '/',
		icon: <MdDashboard />
	},
	{
		key: 'pets',
		label: 'Pets',
		path: '/pets',
		icon: <MdOutlinePets />
	},
	{
		key: 'vacinas',
		label: 'Vacinas',
		path: '/vacinas',
		icon: <TbVaccine />
	},
]

export const DASHBOARD_SIDEBAR_BOTTOM_LINKS = [
	{
		key: 'settings',
		label: 'Configurações',
		path: '/settings',
		icon: <HiOutlineCog />
	},
	{
		key: 'support',
		label: 'Ajuda & Suporte',
		path: '/support',
		icon: <HiOutlineQuestionMarkCircle />
	}
]