import { Backdrop, Button, TextFieldReactHookForm, Typography } from '@wolf-gmbh/lupine-design-system';
import { FieldValues, useForm } from 'react-hook-form';
import WolfLogoSvg from './svgs/WolfLogoSvg';

import './index.scss';

function App() {
  const {
    control,
    handleSubmit,
    formState: { errors },
  } = useForm({ mode: 'onChange' });

  const isDisabled = !!errors?.email;

  const onSubmit = (data: FieldValues) => {
    // Regex for internal email domain validation, it should include exactly one '@' and end with 'wolf.eu'
    const isInternal = /^[a-zA-Z0-9._%+-]+@([a-zA-Z0-9-]+\.)?wolf\.eu$/.test(data?.email);
    if (isInternal) console.log('redirect to', `${import.meta.env.VITE_INTERAL_PATH}?login_hint=${data?.email}`);
    else console.log('redirect to', `${import.meta.env.VITE_EXTERNAL_PATH}?login_hint=${data?.email}`);
  };

  return (
    <Backdrop open>
      <div className={'login-wrapper'}>
        <WolfLogoSvg />
        <Typography variant={'h4'} className={'login-wrapper-heading'}>
          Sign in
        </Typography>
        <TextFieldReactHookForm
          control={control}
          name={'email'}
          className={'login-wrapper-input'}
          label={'Email address'}
          placeholder={'Email address'}
          required
          rules={{
            required: 'Bitte füllen Sie dieses Pflichtfeld aus.',
            pattern: {
              value: /^[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,4}$/i,
              message: 'E-Mail Adresse ist ungültig',
            },
          }}
          fullWidth
        />
        <Button className={'login-wrapper-button'} variant={'contained'} onClick={handleSubmit(onSubmit)} disabled={isDisabled}>
          Submit
        </Button>
      </div>
    </Backdrop>
  );
}

export default App;
