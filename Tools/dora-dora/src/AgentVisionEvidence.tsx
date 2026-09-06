import React from 'react';
import Box from '@mui/material/Box';
import Button from '@mui/material/Button';
import Dialog from '@mui/material/Dialog';
import DialogContent from '@mui/material/DialogContent';
import DialogTitle from '@mui/material/DialogTitle';
import Stack from '@mui/material/Stack';
import Typography from '@mui/material/Typography';
import { useTranslation } from 'react-i18next';
import { getAgentVisionImage, type AgentSessionStep, type AgentVisionAsset } from './Service';
import { Color } from './Theme';

function VisionImage({sessionId, assetId, zh}: {sessionId: number; assetId: string; zh: boolean}) {
	const container = React.useRef<HTMLDivElement>(null);
	const [visible, setVisible] = React.useState(false);
	const [source, setSource] = React.useState('');
	const [message, setMessage] = React.useState('');
	const [opened, setOpened] = React.useState(false);
	const [asset, setAsset] = React.useState<AgentVisionAsset>();
	React.useEffect(() => {
		const element = container.current;
		if (!element) return;
		const observer = new IntersectionObserver(entries => {
			if (entries.some(entry => entry.isIntersecting)) { setVisible(true); observer.disconnect(); }
		});
		observer.observe(element);
		return () => observer.disconnect();
	}, []);
	React.useEffect(() => {
		if (!visible) return;
		let active = true;
		setSource(''); setMessage('');
		getAgentVisionImage(sessionId, assetId).then(result => {
			if (!active) return;
			if (result.success && result.dataUrl?.startsWith('data:image/png;base64,')) { setSource(result.dataUrl); setAsset(result.asset); }
			else setMessage(zh ? '图片不可用或已清理' : 'Image unavailable or removed');
		}).catch(() => { if (active) setMessage(zh ? '图片加载失败' : 'Image could not be loaded'); });
		return () => { active = false; };
	}, [sessionId, assetId, visible, zh]);
	const title = zh ? '游戏取景' : 'Game capture';
	return <Box ref={container} sx={{minWidth: 100, maxWidth: 220}}>
		{source ? <Button onClick={() => setOpened(true)} aria-label={zh ? '放大游戏截图' : 'Enlarge game capture'} sx={{p: 0}}>
			<Box component="img" src={source} alt={title} sx={{maxWidth: '100%', height: 140, objectFit: 'contain', borderRadius: 1}} />
		</Button> : <Typography variant="caption" sx={{color: Color.TextSecondary}}>{message || (zh ? '正在加载截图…' : 'Loading capture…')}</Typography>}
		{asset && <Typography variant="caption" component="div" sx={{color: Color.TextSecondary, overflowWrap: 'anywhere'}}>{asset.entry} · {asset.elapsedSeconds.toFixed(2)}s · {asset.width}×{asset.height}</Typography>}
		<Dialog open={opened} onClose={() => setOpened(false)} maxWidth="lg" fullWidth>
			<DialogTitle>{title}<Button onClick={() => setOpened(false)} sx={{float: 'right'}}>{zh ? '关闭' : 'Close'}</Button></DialogTitle>
			<DialogContent><Box component="img" src={source} alt={title} sx={{display: 'block', maxWidth: '100%', maxHeight: '80vh', objectFit: 'contain', mx: 'auto'}} /></DialogContent>
		</Dialog>
	</Box>;
}

export default function AgentVisionEvidence({step}: {step: AgentSessionStep}) {
	const { i18n } = useTranslation();
	if (step.tool !== 'preview_game' && step.tool !== 'analyze_image') return null;
	const zh = i18n.language.startsWith('zh');
	const result = step.result;
	const assets = Array.isArray(result?.assets) ? result.assets : [];
	const ids = assets.map(asset => asset && typeof asset === 'object' && 'assetId' in asset ? asset.assetId : undefined)
		.filter((id): id is string => typeof id === 'string' && /^\d+-\d+$/.test(id)).slice(0, 3);
	const report = typeof result?.report === 'string' ? result.report : '';
	const model = typeof result?.model === 'string' ? result.model : '';
	return <Stack spacing={1} sx={{mt: 1}}>
		{ids.length > 0 && <Stack direction="row" spacing={1} useFlexGap flexWrap="wrap">{ids.map(id => <VisionImage key={id} sessionId={step.sessionId} assetId={id} zh={zh} />)}</Stack>}
		{model && <Typography variant="caption" sx={{color: Color.TextSecondary}}>{zh ? '看图模型：' : 'Vision model: '}{model}</Typography>}
		{report && <Typography sx={{whiteSpace: 'pre-wrap', color: Color.TextPrimary, fontSize: 14}}>{report}</Typography>}
		{ids.length > 0 && <Typography variant="caption" sx={{color: Color.TextSecondary}}>{zh ? '静态画面证据；操作和游戏逻辑需另行验证。' : 'Still images; controls and gameplay require separate verification.'}</Typography>}
	</Stack>;
}
