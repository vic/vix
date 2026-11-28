// @ts-check
import { defineConfig, fontProviders } from 'astro/config';
import starlight from '@astrojs/starlight';

import mermaid from 'astro-mermaid';
import catppuccin from '@catppuccin/starlight';
// generated directly from the live Vix Yen fleet (`modules/docs/fleet.nix`)
import sidebar from './src/sidebar.json' with { type: 'json' };

// https://astro.build/config
export default defineConfig({
	site: 'https://vix.oeiuwq.com',
	fonts: [
		{
			provider: fontProviders.google(),
			name: 'Victor Mono',
			cssVariable: '--font-victor-mono',
		},
		{
			provider: fontProviders.google(),
			name: 'JetBrains Mono',
			cssVariable: '--font-jetbrains-mono',
		},
	],
	integrations: [
		mermaid({
			theme: 'forest',
			autoTheme: true,
		}),
		starlight({
			title: '{vix}',
			description: 'Vic’s real-world NixOS, macOS, Home Manager, devShell, and Neovim fleet built with Yen.',
			social: [{ icon: 'github', label: 'GitHub', href: 'https://github.com/vic/vix' }],
			sidebar,
			components: {
				Head: './src/components/Head.astro',
				Sidebar: './src/components/Sidebar.astro',
				Footer: './src/components/Footer.astro',
				SocialIcons: './src/components/SocialIcons.astro',
				PageSidebar: './src/components/PageSidebar.astro',
				Header: './src/components/Header.astro',
				Hero: './src/components/Hero.astro',
				TableOfContents: './src/components/TableOfContents.astro',
				ThemeSelect: './src/components/ThemeSelect.astro',
			},
			plugins: [
				catppuccin({
					dark: { flavor: 'mocha', accent: 'mauve' },
					light: { flavor: 'latte', accent: 'mauve' },
				}),
			],
			editLink: {
				baseUrl: 'https://github.com/vic/vix/edit/yen/',
			},
			customCss: ['./src/styles/layout.css', './src/styles/custom.css', './src/styles/yen.css'],
		}),
	],
});
