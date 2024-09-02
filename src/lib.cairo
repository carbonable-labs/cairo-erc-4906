pub mod erc4906_component;
mod presets;

#[cfg(test)]
mod tests {
    mod test_e2e;
    mod utils;
    mod units {
        mod test_batch_metadata_update;
        mod test_initialization;
        mod test_metadata_update;
    }
}
