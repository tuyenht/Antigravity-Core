'use client';

import React, { useState, useCallback, useEffect } from 'react';
import { Offcanvas, OffcanvasBody, Collapse } from 'reactstrap';
import SimpleBar from 'simplebar-react';
import { useLayout } from '@/contexts/LayoutContext';

/**
 * ThemeCustomizer — Exact 1:1 JSX replica of Velzon HTML customizer.html
 * CSS: .customizer-setting { position:fixed; bottom:40px; right:20px; z-index:1000 }
 * 
 * PRUNED per spec:
 * - Semi Box layout: REMOVED
 * - Theme chooser: LOCKED to Default (hidden)
 * - Boxed layout width: REMOVED (locked to Fluid)
 * - Compact sidebar size: REMOVED
 * - Sidebar View: REMOVED (locked to Default)
 * - Sidebar User Profile: REMOVED
 */

/* === Velzon CSS thumbnail: Vertical layout === */
const VerticalThumb = () => (
  <span className="d-flex gap-1 h-100">
    <span className="flex-shrink-0">
      <span className="bg-light d-flex h-100 flex-column gap-1 p-1">
        <span className="d-block p-1 px-2 bg-primary-subtle rounded mb-2"></span>
        <span className="d-block p-1 px-2 pb-0 bg-primary-subtle"></span>
        <span className="d-block p-1 px-2 pb-0 bg-primary-subtle"></span>
        <span className="d-block p-1 px-2 pb-0 bg-primary-subtle"></span>
      </span>
    </span>
    <span className="flex-grow-1">
      <span className="d-flex h-100 flex-column">
        <span className="bg-light d-block p-1"></span>
        <span className="bg-light d-block p-1 mt-auto"></span>
      </span>
    </span>
  </span>
);

/* === Velzon CSS thumbnail: Horizontal layout === */
const HorizontalThumb = () => (
  <span className="d-flex h-100 flex-column gap-1">
    <span className="bg-light d-flex p-1 gap-1 align-items-center">
      <span className="d-block p-1 bg-primary-subtle rounded me-1"></span>
      <span className="d-block p-1 pb-0 px-2 bg-primary-subtle ms-auto"></span>
      <span className="d-block p-1 pb-0 px-2 bg-primary-subtle"></span>
    </span>
    <span className="bg-light d-block p-1"></span>
    <span className="bg-light d-block p-1 mt-auto"></span>
  </span>
);

/* === Velzon CSS thumbnail: Two Column layout === */
const TwoColumnThumb = () => (
  <span className="d-flex gap-1 h-100">
    <span className="flex-shrink-0">
      <span className="bg-light d-flex h-100 flex-column gap-1">
        <span className="d-block p-1 bg-primary-subtle mb-2"></span>
        <span className="d-block p-1 pb-0 bg-primary-subtle"></span>
        <span className="d-block p-1 pb-0 bg-primary-subtle"></span>
        <span className="d-block p-1 pb-0 bg-primary-subtle"></span>
      </span>
    </span>
    <span className="flex-shrink-0">
      <span className="bg-light d-flex h-100 flex-column gap-1 p-1">
        <span className="d-block p-1 px-2 pb-0 bg-primary-subtle"></span>
        <span className="d-block p-1 px-2 pb-0 bg-primary-subtle"></span>
        <span className="d-block p-1 px-2 pb-0 bg-primary-subtle"></span>
        <span className="d-block p-1 px-2 pb-0 bg-primary-subtle"></span>
      </span>
    </span>
    <span className="flex-grow-1">
      <span className="d-flex h-100 flex-column">
        <span className="bg-light d-block p-1"></span>
        <span className="bg-light d-block p-1 mt-auto"></span>
      </span>
    </span>
  </span>
);

/* === Dark mode thumbnail (uses bg-white bg-opacity-10) === */
const DarkThumb = () => (
  <span className="d-flex gap-1 h-100">
    <span className="flex-shrink-0">
      <span className="bg-white bg-opacity-10 d-flex h-100 flex-column gap-1 p-1">
        <span className="d-block p-1 px-2 bg-white bg-opacity-10 rounded mb-2"></span>
        <span className="d-block p-1 px-2 pb-0 bg-white bg-opacity-10"></span>
        <span className="d-block p-1 px-2 pb-0 bg-white bg-opacity-10"></span>
        <span className="d-block p-1 px-2 pb-0 bg-white bg-opacity-10"></span>
      </span>
    </span>
    <span className="flex-grow-1">
      <span className="d-flex h-100 flex-column">
        <span className="bg-white bg-opacity-10 d-block p-1"></span>
        <span className="bg-white bg-opacity-10 d-block p-1 mt-auto"></span>
      </span>
    </span>
  </span>
);

/* === Topbar Dark thumbnail === */
const TopbarDarkThumb = () => (
  <span className="d-flex gap-1 h-100">
    <span className="flex-shrink-0">
      <span className="bg-light d-flex h-100 flex-column gap-1 p-1">
        <span className="d-block p-1 px-2 bg-primary-subtle rounded mb-2"></span>
        <span className="d-block p-1 px-2 pb-0 bg-primary-subtle"></span>
        <span className="d-block p-1 px-2 pb-0 bg-primary-subtle"></span>
        <span className="d-block p-1 px-2 pb-0 bg-primary-subtle"></span>
      </span>
    </span>
    <span className="flex-grow-1">
      <span className="d-flex h-100 flex-column">
        <span className="bg-primary d-block p-1"></span>
        <span className="bg-light d-block p-1 mt-auto"></span>
      </span>
    </span>
  </span>
);

/* === Sidebar light thumbnail === */
const SidebarLightThumb = () => (
  <span className="d-flex gap-1 h-100">
    <span className="flex-shrink-0">
      <span className="bg-white border-end d-flex h-100 flex-column gap-1 p-1">
        <span className="d-block p-1 px-2 bg-primary-subtle rounded mb-2"></span>
        <span className="d-block p-1 px-2 pb-0 bg-primary-subtle"></span>
        <span className="d-block p-1 px-2 pb-0 bg-primary-subtle"></span>
        <span className="d-block p-1 px-2 pb-0 bg-primary-subtle"></span>
      </span>
    </span>
    <span className="flex-grow-1">
      <span className="d-flex h-100 flex-column">
        <span className="bg-light d-block p-1"></span>
        <span className="bg-light d-block p-1 mt-auto"></span>
      </span>
    </span>
  </span>
);

/* === Sidebar dark thumbnail === */
const SidebarDarkThumb = () => (
  <span className="d-flex gap-1 h-100">
    <span className="flex-shrink-0">
      <span className="bg-primary d-flex h-100 flex-column gap-1 p-1">
        <span className="d-block p-1 px-2 bg-white bg-opacity-10 rounded mb-2"></span>
        <span className="d-block p-1 px-2 pb-0 bg-white bg-opacity-10"></span>
        <span className="d-block p-1 px-2 pb-0 bg-white bg-opacity-10"></span>
        <span className="d-block p-1 px-2 pb-0 bg-white bg-opacity-10"></span>
      </span>
    </span>
    <span className="flex-grow-1">
      <span className="d-flex h-100 flex-column">
        <span className="bg-light d-block p-1"></span>
        <span className="bg-light d-block p-1 mt-auto"></span>
      </span>
    </span>
  </span>
);

/* === Sidebar gradient thumbnail === */
const SidebarGradientThumb = () => (
  <span className="d-flex gap-1 h-100">
    <span className="flex-shrink-0">
      <span className="bg-vertical-gradient d-flex h-100 flex-column gap-1 p-1">
        <span className="d-block p-1 px-2 bg-white bg-opacity-10 rounded mb-2"></span>
        <span className="d-block p-1 px-2 pb-0 bg-white bg-opacity-10"></span>
        <span className="d-block p-1 px-2 pb-0 bg-white bg-opacity-10"></span>
        <span className="d-block p-1 px-2 pb-0 bg-white bg-opacity-10"></span>
      </span>
    </span>
    <span className="flex-grow-1">
      <span className="d-flex h-100 flex-column">
        <span className="bg-light d-block p-1"></span>
        <span className="bg-light d-block p-1 mt-auto"></span>
      </span>
    </span>
  </span>
);

/* === Sidebar small icon thumbnail === */
const SidebarSmallThumb = () => (
  <span className="d-flex gap-1 h-100">
    <span className="flex-shrink-0">
      <span className="bg-light d-flex h-100 flex-column gap-1">
        <span className="d-block p-1 bg-primary-subtle mb-2"></span>
        <span className="d-block p-1 pb-0 bg-primary-subtle"></span>
        <span className="d-block p-1 pb-0 bg-primary-subtle"></span>
        <span className="d-block p-1 pb-0 bg-primary-subtle"></span>
      </span>
    </span>
    <span className="flex-grow-1">
      <span className="d-flex h-100 flex-column">
        <span className="bg-light d-block p-1"></span>
        <span className="bg-light d-block p-1 mt-auto"></span>
      </span>
    </span>
  </span>
);

/* === Sidebar visibility show thumbnail === */
const SidebarShowThumb = () => (
  <span className="d-flex gap-1 h-100">
    <span className="flex-shrink-0 p-1">
      <span className="bg-light d-flex h-100 flex-column gap-1 p-1">
        <span className="d-block p-1 px-2 bg-primary-subtle rounded mb-2"></span>
        <span className="d-block p-1 px-2 pb-0 bg-primary-subtle"></span>
        <span className="d-block p-1 px-2 pb-0 bg-primary-subtle"></span>
        <span className="d-block p-1 px-2 pb-0 bg-primary-subtle"></span>
      </span>
    </span>
    <span className="flex-grow-1">
      <span className="d-flex h-100 flex-column pt-1 pe-2">
        <span className="bg-light d-block p-1"></span>
        <span className="bg-light d-block p-1 mt-auto"></span>
      </span>
    </span>
  </span>
);

/* === Sidebar visibility hidden thumbnail === */
const SidebarHiddenThumb = () => (
  <span className="d-flex gap-1 h-100">
    <span className="flex-grow-1">
      <span className="d-flex h-100 flex-column pt-1 px-2">
        <span className="bg-light d-block p-1"></span>
        <span className="bg-light d-block p-1 mt-auto"></span>
      </span>
    </span>
  </span>
);

export default function ThemeCustomizer() {
  const [isOpen, setIsOpen] = useState(false);
  const [gradientOpen, setGradientOpen] = useState(false);
  const { changeLayout } = useLayout();

  const [a, setA] = useState<Record<string, string>>({});

  const readAttrs = useCallback(() => {
    const el = document.documentElement;
    const keys = ['layout','bs-theme','topbar','sidebar-size','sidebar','sidebar-visibility',
      'layout-width','layout-position','theme-colors','sidebar-image','preloader','body-image'];
    const obj: Record<string, string> = {};
    keys.forEach(k => { obj[k] = el.getAttribute(`data-${k}`) || ''; });
    setA(obj);
  }, []);

  useEffect(() => { readAttrs(); }, [readAttrs]);
  useEffect(() => { if (isOpen) readAttrs(); }, [isOpen, readAttrs]);

  const toggle = useCallback(() => setIsOpen(p => !p), []);

  const set = useCallback((attr: string, value: string) => {
    document.documentElement.setAttribute(`data-${attr}`, value);
    sessionStorage.setItem(`data-${attr}`, value);
    setA(p => ({ ...p, [attr]: value }));
    if (attr === 'layout') changeLayout('layout', value);
    if (attr === 'sidebar-size') changeLayout('sidebarSize', value);
  }, [changeLayout]);

  const reset = useCallback(() => {
    const d: Record<string, string> = {
      'layout':'vertical','topbar':'light','sidebar':'dark','sidebar-size':'lg',
      'bs-theme':'light','layout-width':'fluid','layout-position':'fixed',
      'layout-style':'default','theme':'default','theme-colors':'default',
      'preloader':'disable','body-image':'none','sidebar-image':'none',
      'sidebar-visibility':'show',
    };
    Object.entries(d).forEach(([k, v]) => {
      document.documentElement.setAttribute(`data-${k}`, v);
      sessionStorage.setItem(`data-${k}`, v);
    });
    setA(d);
    changeLayout('layout', 'vertical');
    changeLayout('sidebarSize', 'lg');
  }, [changeLayout]);

  return (
    <>
      {/* Gear button — uses Velzon CSS: .customizer-setting { position:fixed; bottom:40px; right:20px; z-index:1000 } */}
      <div className="customizer-setting d-none d-md-block">
        <div
          className="btn-info rounded-pill shadow-lg btn btn-icon btn-lg p-2"
          onClick={toggle}
          style={{ cursor: 'pointer' }}
        >
          <i className="mdi mdi-spin mdi-cog-outline fs-22"></i>
        </div>
      </div>

      {/* Offcanvas panel */}
      <Offcanvas isOpen={isOpen} toggle={toggle} direction="end" className="border-0" style={{ width: '375px' }}>
        {/* Header */}
        <div className="d-flex align-items-center bg-primary bg-gradient p-3 offcanvas-header">
          <h5 className="m-0 me-2 text-white">Theme Customizer</h5>
          <button type="button" className="btn-close btn-close-white ms-auto" onClick={toggle} aria-label="Close"></button>
        </div>

        <OffcanvasBody className="p-0">
          <SimpleBar className="h-100">
            <div className="p-4">

              {/* === Layout === */}
              <h6 className="mb-0 fw-semibold text-uppercase">Layout</h6>
              <p className="text-muted">Choose your layout</p>
              <div className="row gy-3">
                {([
                  { id: '01', value: 'vertical', label: 'Vertical', Thumb: VerticalThumb },
                  { id: '02', value: 'horizontal', label: 'Horizontal', Thumb: HorizontalThumb },
                  { id: '03', value: 'twocolumn', label: 'Two Column', Thumb: TwoColumnThumb },
                ] as const).map(({ id, value, label, Thumb }) => (
                  <div className="col-4" key={id}>
                    <div className="form-check card-radio">
                      <input className="form-check-input" type="radio" name="data-layout" id={`customizer-layout${id}`} value={value} checked={a.layout === value} onChange={() => set('layout', value)} />
                      <label className="form-check-label p-0 avatar-md w-100 material-shadow" htmlFor={`customizer-layout${id}`}>
                        <Thumb />
                      </label>
                    </div>
                    <h5 className="fs-13 text-center mt-2">{label}</h5>
                  </div>
                ))}
              </div>

              {/* Theme: LOCKED to Default */}
              <input type="hidden" name="data-theme" value="default" />

              {/* === Color Scheme === */}
              <h6 className="mt-4 mb-0 fw-semibold text-uppercase">Color Scheme</h6>
              <p className="text-muted">Choose Light or Dark Scheme.</p>
              <div className="colorscheme-cardradio">
                <div className="row">
                  <div className="col-4">
                    <div className="form-check card-radio">
                      <input className="form-check-input" type="radio" name="data-bs-theme" id="layout-mode-light" value="light" checked={a['bs-theme'] === 'light'} onChange={() => set('bs-theme', 'light')} />
                      <label className="form-check-label p-0 avatar-md w-100 material-shadow" htmlFor="layout-mode-light"><VerticalThumb /></label>
                    </div>
                    <h5 className="fs-13 text-center mt-2">Light</h5>
                  </div>
                  <div className="col-4">
                    <div className="form-check card-radio dark">
                      <input className="form-check-input" type="radio" name="data-bs-theme" id="layout-mode-dark" value="dark" checked={a['bs-theme'] === 'dark'} onChange={() => set('bs-theme', 'dark')} />
                      <label className="form-check-label p-0 avatar-md w-100 bg-dark material-shadow" htmlFor="layout-mode-dark"><DarkThumb /></label>
                    </div>
                    <h5 className="fs-13 text-center mt-2">Dark</h5>
                  </div>
                </div>
              </div>

              {/* === Sidebar Visibility === */}
              <div id="sidebar-visibility">
                <h6 className="mt-4 mb-0 fw-semibold text-uppercase">Sidebar Visibility</h6>
                <p className="text-muted">Choose show or Hidden sidebar.</p>
                <div className="row">
                  <div className="col-4">
                    <div className="form-check card-radio">
                      <input className="form-check-input" type="radio" name="data-sidebar-visibility" id="sidebar-visibility-show" value="show" checked={a['sidebar-visibility'] === 'show'} onChange={() => set('sidebar-visibility', 'show')} />
                      <label className="form-check-label p-0 avatar-md w-100 material-shadow" htmlFor="sidebar-visibility-show"><SidebarShowThumb /></label>
                    </div>
                    <h5 className="fs-13 text-center mt-2">Show</h5>
                  </div>
                  <div className="col-4">
                    <div className="form-check card-radio">
                      <input className="form-check-input" type="radio" name="data-sidebar-visibility" id="sidebar-visibility-hidden" value="hidden" checked={a['sidebar-visibility'] === 'hidden'} onChange={() => set('sidebar-visibility', 'hidden')} />
                      <label className="form-check-label p-0 avatar-md w-100 px-2 material-shadow" htmlFor="sidebar-visibility-hidden"><SidebarHiddenThumb /></label>
                    </div>
                    <h5 className="fs-13 text-center mt-2">Hidden</h5>
                  </div>
                </div>
              </div>

              {/* === Layout Width (Fluid only) === */}
              <div id="layout-width">
                <h6 className="mt-4 mb-0 fw-semibold text-uppercase">Layout Width</h6>
                <p className="text-muted">Choose Fluid layout.</p>
                <div className="row">
                  <div className="col-4">
                    <div className="form-check card-radio">
                      <input className="form-check-input" type="radio" name="data-layout-width" id="layout-width-fluid" value="fluid" checked={true} readOnly />
                      <label className="form-check-label p-0 avatar-md w-100 material-shadow" htmlFor="layout-width-fluid"><VerticalThumb /></label>
                    </div>
                    <h5 className="fs-13 text-center mt-2">Fluid</h5>
                  </div>
                </div>
              </div>

              {/* === Layout Position === */}
              <div id="layout-position">
                <h6 className="mt-4 mb-0 fw-semibold text-uppercase">Layout Position</h6>
                <p className="text-muted">Choose Fixed or Scrollable Layout Position.</p>
                <div className="btn-group radio" role="group">
                  <input type="radio" className="btn-check" name="data-layout-position" id="layout-position-fixed" value="fixed" checked={a['layout-position'] === 'fixed'} onChange={() => set('layout-position', 'fixed')} />
                  <label className="btn btn-light w-sm" htmlFor="layout-position-fixed">Fixed</label>
                  <input type="radio" className="btn-check" name="data-layout-position" id="layout-position-scrollable" value="scrollable" checked={a['layout-position'] === 'scrollable'} onChange={() => set('layout-position', 'scrollable')} />
                  <label className="btn btn-light w-sm ms-0" htmlFor="layout-position-scrollable">Scrollable</label>
                </div>
              </div>

              {/* === Topbar Color === */}
              <h6 className="mt-4 mb-0 fw-semibold text-uppercase">Topbar Color</h6>
              <p className="text-muted">Choose Light or Dark Topbar Color.</p>
              <div className="row">
                <div className="col-4">
                  <div className="form-check card-radio">
                    <input className="form-check-input" type="radio" name="data-topbar" id="topbar-color-light" value="light" checked={a.topbar === 'light'} onChange={() => set('topbar', 'light')} />
                    <label className="form-check-label p-0 avatar-md w-100 material-shadow" htmlFor="topbar-color-light"><VerticalThumb /></label>
                  </div>
                  <h5 className="fs-13 text-center mt-2">Light</h5>
                </div>
                <div className="col-4">
                  <div className="form-check card-radio">
                    <input className="form-check-input" type="radio" name="data-topbar" id="topbar-color-dark" value="dark" checked={a.topbar === 'dark'} onChange={() => set('topbar', 'dark')} />
                    <label className="form-check-label p-0 avatar-md w-100 material-shadow" htmlFor="topbar-color-dark"><TopbarDarkThumb /></label>
                  </div>
                  <h5 className="fs-13 text-center mt-2">Dark</h5>
                </div>
              </div>

              {/* === Sidebar Size === */}
              <div id="sidebar-size">
                <h6 className="mt-4 mb-0 fw-semibold text-uppercase">Sidebar Size</h6>
                <p className="text-muted">Choose a size of Sidebar.</p>
                <div className="row">
                  <div className="col-4">
                    <div className="form-check sidebar-setting card-radio">
                      <input className="form-check-input" type="radio" name="data-sidebar-size" id="sidebar-size-default" value="lg" checked={a['sidebar-size'] === 'lg'} onChange={() => set('sidebar-size', 'lg')} />
                      <label className="form-check-label p-0 avatar-md w-100 material-shadow" htmlFor="sidebar-size-default"><VerticalThumb /></label>
                    </div>
                    <h5 className="fs-13 text-center mt-2">Default</h5>
                  </div>
                  <div className="col-4">
                    <div className="form-check sidebar-setting card-radio">
                      <input className="form-check-input" type="radio" name="data-sidebar-size" id="sidebar-size-small" value="sm" checked={a['sidebar-size'] === 'sm'} onChange={() => set('sidebar-size', 'sm')} />
                      <label className="form-check-label p-0 avatar-md w-100 material-shadow" htmlFor="sidebar-size-small"><SidebarSmallThumb /></label>
                    </div>
                    <h5 className="fs-13 text-center mt-2">Small (Icon View)</h5>
                  </div>
                  <div className="col-4">
                    <div className="form-check sidebar-setting card-radio">
                      <input className="form-check-input" type="radio" name="data-sidebar-size" id="sidebar-size-small-hover" value="sm-hover" checked={a['sidebar-size'] === 'sm-hover'} onChange={() => set('sidebar-size', 'sm-hover')} />
                      <label className="form-check-label p-0 avatar-md w-100 material-shadow" htmlFor="sidebar-size-small-hover"><SidebarSmallThumb /></label>
                    </div>
                    <h5 className="fs-13 text-center mt-2">Small Hover View</h5>
                  </div>
                </div>
              </div>

              {/* Sidebar View: REMOVED — locked to Default */}
              <input type="hidden" name="data-layout-style" value="default" />

              {/* === Sidebar Color === */}
              <div id="sidebar-color">
                <h6 className="mt-4 mb-0 fw-semibold text-uppercase">Sidebar Color</h6>
                <p className="text-muted">Choose a color of Sidebar.</p>
                <div className="row">
                  <div className="col-4">
                    <div className="form-check sidebar-setting card-radio" onClick={() => { set('sidebar', 'light'); setGradientOpen(false); }}>
                      <input className="form-check-input" type="radio" name="data-sidebar" id="sidebar-color-light" value="light" checked={a.sidebar === 'light'} onChange={() => {}} />
                      <label className="form-check-label p-0 avatar-md w-100 material-shadow" htmlFor="sidebar-color-light"><SidebarLightThumb /></label>
                    </div>
                    <h5 className="fs-13 text-center mt-2">Light</h5>
                  </div>
                  <div className="col-4">
                    <div className="form-check sidebar-setting card-radio" onClick={() => { set('sidebar', 'dark'); setGradientOpen(false); }}>
                      <input className="form-check-input" type="radio" name="data-sidebar" id="sidebar-color-dark" value="dark" checked={a.sidebar === 'dark'} onChange={() => {}} />
                      <label className="form-check-label p-0 avatar-md w-100 material-shadow" htmlFor="sidebar-color-dark"><SidebarDarkThumb /></label>
                    </div>
                    <h5 className="fs-13 text-center mt-2">Dark</h5>
                  </div>
                  <div className="col-4">
                    <button className="btn btn-link avatar-md w-100 p-0 overflow-hidden border collapsed" type="button" onClick={() => setGradientOpen(!gradientOpen)}>
                      <SidebarGradientThumb />
                    </button>
                    <h5 className="fs-13 text-center mt-2">Gradient</h5>
                  </div>
                </div>
                <Collapse isOpen={gradientOpen}>
                  <div className="d-flex gap-2 flex-wrap img-switch p-2 px-3 bg-light rounded">
                    {(['gradient', 'gradient-2', 'gradient-3', 'gradient-4'] as const).map((v, i) => (
                      <div className="form-check sidebar-setting card-radio" key={v}>
                        <input className="form-check-input" type="radio" name="data-sidebar" id={`sidebar-color-${v}`} value={v} checked={a.sidebar === v} onChange={() => set('sidebar', v)} />
                        <label className="form-check-label p-0 avatar-xs rounded-circle" htmlFor={`sidebar-color-${v}`}>
                          <span className={`avatar-title rounded-circle bg-vertical-gradient${i > 0 ? `-${i + 1}` : ''}`}></span>
                        </label>
                      </div>
                    ))}
                  </div>
                </Collapse>
              </div>

              {/* === Sidebar Images === */}
              <div id="sidebar-img">
                <h6 className="mt-4 mb-0 fw-semibold text-uppercase">Sidebar Images</h6>
                <p className="text-muted">Choose a image of Sidebar.</p>
                <div className="d-flex gap-2 flex-wrap img-switch">
                  <div className="form-check sidebar-setting card-radio">
                    <input className="form-check-input" type="radio" name="data-sidebar-image" id="sidebarimg-none" value="none" checked={a['sidebar-image'] === 'none' || !a['sidebar-image']} onChange={() => set('sidebar-image', 'none')} />
                    <label className="form-check-label p-0 avatar-sm h-auto" htmlFor="sidebarimg-none">
                      <span className="avatar-md w-auto bg-light d-flex align-items-center justify-content-center">
                        <i className="ri-close-fill fs-20"></i>
                      </span>
                    </label>
                  </div>
                  {[1, 2, 3, 4].map(n => (
                    <div className="form-check sidebar-setting card-radio" key={n}>
                      <input className="form-check-input" type="radio" name="data-sidebar-image" id={`sidebarimg-0${n}`} value={`img-${n}`} checked={a['sidebar-image'] === `img-${n}`} onChange={() => set('sidebar-image', `img-${n}`)} />
                      <label className="form-check-label p-0 avatar-sm h-auto" htmlFor={`sidebarimg-0${n}`}>
                        <img src={`/assets/images/sidebar/img-${n}.jpg`} alt="" className="avatar-md w-auto object-fit-cover" />
                      </label>
                    </div>
                  ))}
                </div>
              </div>

              {/* === Primary Color === */}
              <div>
                <h6 className="mt-4 mb-0 fw-semibold text-uppercase">Primary Color</h6>
                <p className="text-muted">Choose a color of Primary.</p>
                <div className="d-flex flex-wrap gap-2">
                  {(['default', 'green', 'purple', 'blue'] as const).map((v, i) => (
                    <div className="form-check sidebar-setting card-radio" key={v}>
                      <input className="form-check-input" type="radio" name="data-theme-colors" id={`themeColor-0${i + 1}`} value={v} checked={a['theme-colors'] === v} onChange={() => set('theme-colors', v)} />
                      <label className="form-check-label avatar-xs p-0" htmlFor={`themeColor-0${i + 1}`}></label>
                    </div>
                  ))}
                </div>
              </div>

              {/* === Preloader === */}
              <div id="preloader-menu">
                <h6 className="mt-4 mb-0 fw-semibold text-uppercase">Preloader</h6>
                <p className="text-muted">Choose a preloader.</p>
                <div className="row">
                  <div className="col-4">
                    <div className="form-check sidebar-setting card-radio">
                      <input className="form-check-input" type="radio" name="data-preloader" id="preloader-view-custom" value="enable" checked={a.preloader === 'enable'} onChange={() => set('preloader', 'enable')} />
                      <label className="form-check-label p-0 avatar-md w-100 material-shadow" htmlFor="preloader-view-custom">
                        <VerticalThumb />
                        <div className="d-flex align-items-center justify-content-center" style={{ position: 'absolute', inset: 0 }}>
                          <div className="spinner-border text-primary avatar-xxs m-auto" role="status">
                            <span className="visually-hidden">Loading...</span>
                          </div>
                        </div>
                      </label>
                    </div>
                    <h5 className="fs-13 text-center mt-2">Enable</h5>
                  </div>
                  <div className="col-4">
                    <div className="form-check sidebar-setting card-radio">
                      <input className="form-check-input" type="radio" name="data-preloader" id="preloader-view-none" value="disable" checked={a.preloader === 'disable' || !a.preloader} onChange={() => set('preloader', 'disable')} />
                      <label className="form-check-label p-0 avatar-md w-100 material-shadow" htmlFor="preloader-view-none"><VerticalThumb /></label>
                    </div>
                    <h5 className="fs-13 text-center mt-2">Disable</h5>
                  </div>
                </div>
              </div>

            </div>
          </SimpleBar>
        </OffcanvasBody>

        {/* Footer */}
        <div className="offcanvas-footer border-top p-3 text-center">
          <div className="row">
            <div className="col-6">
              <button type="button" className="btn btn-light w-100" onClick={reset}>Reset</button>
            </div>
            <div className="col-6">
              <button type="button" className="btn btn-primary w-100" onClick={toggle}>Close</button>
            </div>
          </div>
        </div>
      </Offcanvas>
    </>
  );
}
