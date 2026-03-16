'use client';

import React, { useState } from 'react';
import { Dropdown, DropdownItem, DropdownMenu, DropdownToggle } from 'reactstrap';
import { useLocale, type SupportedLocale } from '@/contexts/LocaleContext';

/**
 * LanguageDropdown — Velzon Header Language Switcher
 * 
 * Adaptation for Next.js standalone:
 * - Uses LocaleContext (useLocale) instead of i18next/lodash
 * - Shows flag image of selected language (NOT globe icon)
 * - Persists selection in localStorage('I18N_LANGUAGE')
 * - setLocale() triggers context-wide translation update (no page reload)
 * 
 * REQUIRED: Flags at /assets/images/flags/ (us.svg, vn.svg, jp.svg, cn.svg)
 * REQUIRED: LocaleProvider wrapping the layout
 */

const LANGUAGES: { code: SupportedLocale; label: string; flag: string }[] = [
  { code: 'en', label: 'English', flag: '/assets/images/flags/us.svg' },
  { code: 'vi', label: 'Tiếng Việt', flag: '/assets/images/flags/vn.svg' },
  { code: 'ja', label: '日本語', flag: '/assets/images/flags/jp.svg' },
  { code: 'zh', label: '中文', flag: '/assets/images/flags/cn.svg' },
];

const LanguageDropdown = () => {
  const [isOpen, setIsOpen] = useState(false);
  const { locale, setLocale } = useLocale();

  const selectedLang = LANGUAGES.find(l => l.code === locale) || LANGUAGES[0];

  const toggle = () => setIsOpen(!isOpen);

  const changeLanguage = (lang: typeof LANGUAGES[0]) => {
    localStorage.setItem('I18N_LANGUAGE', lang.code);
    setLocale(lang.code);
    setIsOpen(false);
  };

  return (
    <Dropdown isOpen={isOpen} toggle={toggle} className="ms-1 topbar-head-dropdown header-item">
      <DropdownToggle className="btn btn-icon btn-topbar btn-ghost-secondary rounded-circle" tag="button">
        <img
          src={selectedLang.flag}
          alt={selectedLang.label}
          height="20"
          className="rounded"
        />
      </DropdownToggle>
      <DropdownMenu className="notify-item language py-2">
        {LANGUAGES.map((lang) => (
          <DropdownItem
            key={lang.code}
            onClick={() => changeLanguage(lang)}
            className={`notify-item ${selectedLang.code === lang.code ? 'active' : ''}`}
          >
            <img src={lang.flag} alt={lang.label} className="me-2 rounded" height="18" />
            <span className="align-middle">{lang.label}</span>
          </DropdownItem>
        ))}
      </DropdownMenu>
    </Dropdown>
  );
};

export default LanguageDropdown;