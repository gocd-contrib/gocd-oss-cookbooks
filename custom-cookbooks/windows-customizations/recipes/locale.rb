# Set the locale to 'Chinese (Simplified, PRC)'
# Run `choco install regshot` and run `RegShot-unicode.exe`
# before and after making locale changes to see
# what has changed

registry_key 'HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Nls\CodePage' do
  values [
    {
      name: 'ACP',
      type: :string,
      data: '936'
    },
    {
      name: 'OEMCP',
      type: :string,
      data: '936'
    },
    {
      name: 'MACCP',
      type: :string,
      data: '10008'
    },
  ]
end

registry_key 'HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Nls\Language' do
  values [
    {
      name: 'Default',
      type: :string,
      data: '0804'
    }
  ]
end

registry_key 'HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Nls\Locale' do
  values [
    {
      name: '(Default)',
      type: :string,
      data: '00000804'
    }
  ]
end
